cmake_minimum_required(VERSION 3.22)
project(VSORT_Package)

# === C++ Standard & Options ===
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Options
set(ENABLE_CUDA OFF CACHE BOOL "Enable CUDA backend")
set(ENABLE_DML OFF CACHE BOOL "Enable DirectML backend")
set(ENABLE_COREML OFF CACHE BOOL "Enable CoreML support")

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
find_package(onnxruntime REQUIRED)

if(ENABLE_CUDA)
  find_package(CUDAToolkit REQUIRED)
endif()

# === Target Definition & Configuration ===
add_library(
  vsort
  SHARED
  vs-mlrt/vsort/vs_onnxruntime.cpp
  vs-mlrt/vsort/win32.cpp
  vs-mlrt/common/onnx_utils.cpp
  vs-mlrt/common/convert_float_to_float16.cpp
)

set_target_properties(
  vsort
  PROPERTIES POSITION_INDEPENDENT_CODE ON CXX_EXTENSIONS OFF CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
)

if(UNIX)
  if(APPLE)
    set_target_properties(vsort PROPERTIES INSTALL_RPATH "@loader_path")
  else()
    set_target_properties(vsort PROPERTIES INSTALL_RPATH "$ORIGIN")
  endif()
endif()

target_include_directories(
  vsort
  PRIVATE "${VAPOURSYNTH_INCLUDE_DIRECTORY}" "vs-mlrt/vsort" "vs-mlrt/common"
  PUBLIC "${PROJECT_BINARY_DIR}"
)

if(ENABLE_CUDA)
  target_compile_definitions(vsort PRIVATE ENABLE_CUDA)
  target_include_directories(vsort PRIVATE ${CUDAToolkit_INCLUDE_DIRS})
endif()

if(ENABLE_DML)
  target_compile_definitions(vsort PRIVATE ENABLE_DML)
endif()

if(ENABLE_COREML)
  target_compile_definitions(vsort PRIVATE ENABLE_COREML=1)
endif()

configure_file(vs-mlrt/vsort/config.h.in config.h)

# === Link Libraries Setup ===
target_link_libraries(vsort PRIVATE ONNX::onnx onnxruntime::onnxruntime)

if(MSVC)
  target_link_options(vsort PRIVATE "/DELAYLOAD:onnxruntime.dll" "delayimp.lib")
endif()

if(ENABLE_CUDA)
  target_link_libraries(vsort PRIVATE CUDA::cudart_static)
endif()

# === Packaging & Installation ===
install(TARGETS vsort LIBRARY DESTINATION . RUNTIME DESTINATION .)

# Helper runtime DLL/SO copying/installing logic
if(WIN32)
  # Copy ONNX Runtime
  get_filename_component(_ROOT "${onnxruntime_DIR}/../../.." ABSOLUTE)
  file(GLOB _DLLS "${_ROOT}/bin/*.dll")
  # Copy CUDA providers DLL if CUDA is enabled
  if(ENABLE_CUDA)
    file(GLOB _LIB_DLLS "${_ROOT}/lib/*.dll")
    list(APPEND _DLLS ${_LIB_DLLS})
  endif()

  if(_DLLS)
    install(FILES ${_DLLS} DESTINATION "vsort")
  else()
    message(WARNING "Could not find ONNX Runtime DLLs")
  endif()

  if(ENABLE_DML)
    if(NOT DML_DIR AND DEFINED ENV{DML_DIR})
      set(DML_DIR "$ENV{DML_DIR}")
    endif()

    if(DML_DIR)
      file(TO_CMAKE_PATH "${DML_DIR}" _DML_DIR)
      find_file(_DML NAMES DirectML.dll PATHS "${_DML_DIR}/bin/x64-win" NO_DEFAULT_PATH)
    endif()

    if(_DML)
      install(FILES "${_DML}" DESTINATION "vsort")
    else()
      message(WARNING "Could not find DirectML DLL. DML_DIR='${DML_DIR}'")
    endif()
  endif()

  if(ENABLE_CUDA)
    # Convert Windows paths to CMake paths (backslashes -> forward slashes) to avoid string parsing syntax errors
    if(DEFINED ENV{CUDA_PATH})
      file(TO_CMAKE_PATH "$ENV{CUDA_PATH}" _CUDA_PATH)
    endif()
    if(DEFINED ENV{CUDNN_PATH})
      file(TO_CMAKE_PATH "$ENV{CUDNN_PATH}" _CUDNN_PATH)
    endif()
    if(DEFINED ENV{CUDNN_HOME})
      file(TO_CMAKE_PATH "$ENV{CUDNN_HOME}" _CUDNN_HOME)
    endif()

    # Copy CUDA Toolkit DLLs
    file(
      GLOB _CUDA_DLLS
      "${_CUDA_PATH}/bin/x64/cublas64_*.dll"
      "${_CUDA_PATH}/bin/x64/cublasLt64_*.dll"
      "${_CUDA_PATH}/bin/x64/cudart64_*.dll"
      "${_CUDA_PATH}/bin/x64/cufft64_*.dll"
      "${_CUDA_PATH}/bin/x64/cufftw64_*.dll"
      "${_CUDA_PATH}/bin/x64/nvblas64_*.dll"
      "${_CUDA_PATH}/extras/CUPTI/lib64/cupti64_*.dll"
    )

    # Copy cuDNN DLLs
    file(
      GLOB _CUDNN_DLLS
      "${_CUDNN_PATH}/bin/*.dll"
      "${_CUDNN_HOME}/bin/*.dll"
      "${_CUDNN_PATH}/bin/x64/*.dll"
      "${_CUDNN_HOME}/bin/x64/*.dll"
    )

    set(_ALL_CUDA_DLLS ${_CUDA_DLLS} ${_CUDNN_DLLS})
    if(_ALL_CUDA_DLLS)
      message(STATUS "Found CUDA and cuDNN DLLs to bundle: ${_ALL_CUDA_DLLS}")
      install(FILES ${_ALL_CUDA_DLLS} DESTINATION "vsmlrt-cuda")
    else()
      message(
        WARNING
        "Could not find CUDA or cuDNN DLLs to bundle. CUDA_PATH='${_CUDA_PATH}', CUDNN_PATH='${_CUDNN_PATH}'"
      )
    endif()
  endif()
endif()

# Copy CUDA provider shared libraries on Linux (mirrors the Windows DLL bundling above).
# These are dlopen'd at runtime by libonnxruntime.so and invisible to auditwheel.
if(UNIX AND NOT APPLE AND ENABLE_CUDA)
  get_filename_component(_ROOT "${onnxruntime_DIR}/../../.." ABSOLUTE)
  file(
    GLOB _PROVIDER_LIBS
    "${_ROOT}/lib/libonnxruntime.so"
    "${_ROOT}/lib64/libonnxruntime.so"
    "${_ROOT}/lib/libonnxruntime_providers_cuda.so"
    "${_ROOT}/lib/libonnxruntime_providers_shared.so"
    "${_ROOT}/lib64/libonnxruntime_providers_cuda.so"
    "${_ROOT}/lib64/libonnxruntime_providers_shared.so"
  )
  if(_PROVIDER_LIBS)
    install(FILES ${_PROVIDER_LIBS} DESTINATION .)
  else()
    message(WARNING "Could not find ONNX Runtime CUDA provider libraries in ${_ROOT}")
  endif()
endif()

# Write VapourSynth Manifest
if(WIN32)
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nvsort\n")
else()
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nlibvsort\n")
endif()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" DESTINATION .)
