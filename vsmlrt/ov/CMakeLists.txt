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
    install(FILES ${_LIBS} DESTINATION ".")
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
