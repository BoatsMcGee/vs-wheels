cmake_minimum_required(VERSION 3.22)
project(VSOV_Package)

# === C++ Standard & Options ===
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Options
set(WIN32_SHARED_OPENVINO OFF CACHE BOOL "Build for win32 with shared openvino library")

set(
  VAPOURSYNTH_INCLUDE_DIRECTORY
  "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include"
  CACHE PATH
  "Path to VapourSynth headers"
)

if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
  set(CMAKE_DISABLE_FIND_PACKAGE_Git ON)
endif()

# === Dependencies ===
find_package(Protobuf REQUIRED CONFIG)
find_package(ONNX REQUIRED)
find_package(OpenVINO REQUIRED CONFIG)

# === Target Definition & Configuration ===
add_library(
  vsov
  SHARED
  vs-mlrt/vsov/vs_openvino.cpp
  vs-mlrt/vsov/win32.cpp
  vs-mlrt/common/onnx_utils.cpp
  vs-mlrt/common/convert_float_to_float16.cpp
)

set_target_properties(
  vsov
  PROPERTIES POSITION_INDEPENDENT_CODE ON CXX_EXTENSIONS OFF CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
)

if(UNIX)
  if(APPLE)
    set_target_properties(vsov PROPERTIES INSTALL_RPATH "@loader_path")
  else()
    set_target_properties(vsov PROPERTIES INSTALL_RPATH "$ORIGIN")
  endif()
endif()

target_include_directories(
  vsov
  PRIVATE "${VAPOURSYNTH_INCLUDE_DIRECTORY}" "vs-mlrt/vsov" "vs-mlrt/common"
  PUBLIC "${PROJECT_BINARY_DIR}"
)

if(WIN32_SHARED_OPENVINO)
  target_compile_definitions(vsov PRIVATE WIN32_SHARED_OPENVINO)
endif()

configure_file(vs-mlrt/vsov/config.h.in config.h)

# === Link Libraries Setup ===
target_link_libraries(vsov PRIVATE ONNX::onnx openvino::runtime)

if(WIN32)
  if(WIN32_SHARED_OPENVINO)
    target_link_options(vsov PRIVATE "/DELAYLOAD:openvino.dll" "delayimp.lib")
  else()
    target_link_options(vsov PRIVATE "/DELAYLOAD:tbb.dll" "delayimp.lib")
  endif()
endif()

# === Packaging & Installation ===
install(TARGETS vsov LIBRARY DESTINATION . RUNTIME DESTINATION .)

# Helper runtime DLL/SO copying/installing logic
if(WIN32)
  if(WIN32_SHARED_OPENVINO)
    # Copy OpenVINO Runtime DLLs
    file(
      GLOB _DLLS
      "${OpenVINO_DIR}/../bin/intel64/Release/*.dll"
      "${OpenVINO_DIR}/../bin/intel64/Release/*.json"
      "${OpenVINO_DIR}/../../bin/intel64/Release/*.dll"
      "${OpenVINO_DIR}/../../bin/intel64/Release/*.json"
    )
    # Copy TBB DLL too as OpenVINO depends on it
    file(
      GLOB _TBB_DLL
      "${OpenVINO_DIR}/../3rdparty/tbb/bin/tbb12.dll"
      "${OpenVINO_DIR}/../../3rdparty/tbb/bin/tbb12.dll"
    )
    list(APPEND _DLLS ${_TBB_DLL})
  else()
    # Copy TBB DLL
    file(GLOB _DLLS "${OpenVINO_DIR}/../3rdparty/tbb/bin/tbb12.dll" "${OpenVINO_DIR}/../../3rdparty/tbb/bin/tbb12.dll")
  endif()

  if(_DLLS)
    install(FILES ${_DLLS} DESTINATION "vsov")
  else()
    message(WARNING "Could not find OpenVINO/TBB DLLs")
  endif()
else()
  # Copy OpenVINO plugins and dynamic libraries for Linux/macOS.
  # These are dlopen'd at runtime so auditwheel/delocate can't auto-discover them.
  file(
    GLOB _LIBS
    "${OpenVINO_DIR}/../lib/intel64/*.so"
    "${OpenVINO_DIR}/../lib/intel64/*.so.*"
    "${OpenVINO_DIR}/../lib/intel64/*.json"
    "${OpenVINO_DIR}/../lib/aarch64/*.so"
    "${OpenVINO_DIR}/../lib/aarch64/*.so.*"
    "${OpenVINO_DIR}/../lib/arm64/Release/*.so"
    "${OpenVINO_DIR}/../lib/arm64/Release/*.dylib"
  )
  if(_LIBS)
    set(
      _SKIP_NAMES
      "libopenvino.so"
      "libopenvino_c.so"
      "libopenvino_onnx_frontend.so"
      "libopenvino.dylib"
      "libopenvino_c.dylib"
      "libopenvino_onnx_frontend.dylib"
    )
    foreach(_LIB IN LISTS _LIBS)
      get_filename_component(_LIB_NAME "${_LIB}" NAME)

      # Skip link-time names (which are duplicates of SONAME libraries)
      if(_LIB_NAME IN_LIST _SKIP_NAMES)
        continue()
      endif()

      # Skip full version files to avoid duplicates (e.g. libopenvino.so.2026.1.0)
      if(_LIB_NAME MATCHES "\\.so\\.[0-9]+\\.[0-9]+" OR _LIB_NAME MATCHES "\\.[0-9]+\\.[0-9]+\\.dylib")
        continue()
      endif()

      file(REAL_PATH "${_LIB}" _REAL_LIB)
      install(FILES "${_REAL_LIB}" DESTINATION . RENAME "${_LIB_NAME}")

      if(APPLE)
        # Fix install name ID of the library itself
        install(
          CODE
            "
          execute_process(
            COMMAND install_name_tool -id \"@rpath/${_LIB_NAME}\" \"\${CMAKE_INSTALL_PREFIX}/${_LIB_NAME}\"
          )
        "
        )
        # Fix references to this library in other libraries/plugins
        foreach(_DEP IN LISTS _LIBS "vsov")
          if(_DEP STREQUAL "vsov")
            set(_DEP_NAME "libvsov.dylib")
          else()
            get_filename_component(_DEP_NAME "${_DEP}" NAME)
          endif()
          install(
            CODE
              "
            execute_process(
              COMMAND install_name_tool -change \"${_REAL_LIB}\" \"@rpath/${_LIB_NAME}\" \"\${CMAKE_INSTALL_PREFIX}/${_DEP_NAME}\"
            )
          "
          )
        endforeach()
      endif()
    endforeach()
  else()
    message(WARNING "Could not find OpenVINO libraries/plugins")
  endif()
endif()

# Write VapourSynth Manifest
if(WIN32)
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nvsov\n")
else()
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nlibvsov\n")
endif()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" DESTINATION .)
