cmake_minimum_required(VERSION 3.22)

if(NOT DEFINED SKBUILD_PROJECT_VERSION)
  set(SKBUILD_PROJECT_VERSION "0.0.0")
endif()

project(DFTTEST2_CUDA_Package VERSION "${SKBUILD_PROJECT_VERSION}" LANGUAGES CXX)

# === Apply patches ===
# Opt-in: enables the nvidia PyPI wheel DLL search directories that only exist for
# CUDA 12 builds. Defaults to OFF so a plain (CUDA 13) build compiles the upstream
# source unchanged; CUDA 12 builds enable it explicitly.
set(APPLY_NVIDIA_WHEEL_PATHS
    OFF
    CACHE BOOL "Apply nvidia-wheel-paths.patch (CUDA 12 wheel DLL search paths)"
)

set(SRC_DFTTEST2_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vs-dfttest2")

if(APPLY_NVIDIA_WHEEL_PATHS)
  include("${CMAKE_CURRENT_SOURCE_DIR}/ApplyPatch.cmake")
  add_patched_source(
    PATCHED_WIN32
    "${SRC_DFTTEST2_DIR}/cuda_source/win32.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/patches/nvidia-wheel-paths.patch"
  )
else()
  set(PATCHED_WIN32 "${SRC_DFTTEST2_DIR}/cuda_source/win32.cpp")
endif()

# === C++ Standard & Options ===
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# === VapourSynth Include Resolution ===
find_path(
  VAPOURSYNTH_INCLUDE_DIR
  NAMES VapourSynth4.h VapourSynth.h
  HINTS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../.venv/Lib/site-packages/vapoursynth/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/.venv/Lib/site-packages/vapoursynth/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../vapoursynth/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth"
    "${CMAKE_CURRENT_SOURCE_DIR}/.venv/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/.venv/Lib/site-packages/vapoursynth"
  PATH_SUFFIXES vapoursynth/include vapoursynth include
  DOC "Path to VapourSynth headers"
)

if(VAPOURSYNTH_INCLUDE_DIR)
  message(STATUS "Found VapourSynth headers: ${VAPOURSYNTH_INCLUDE_DIR}")
else()
  message(FATAL_ERROR "VapourSynth headers not found. Ensure vapoursynth>=75 is installed.")
endif()

# === Dependencies ===
find_package(CUDAToolkit REQUIRED)

# DLL name for cufft delay-load (CUDA 12 uses cufft64_11.dll, CUDA 13 uses cufft64_12.dll)
set(CUFFTT_DELAYLOAD_DLL
    "cufft64_12.dll"
    CACHE STRING "DLL name for cufft delay-load"
)

# === Fatbin Generation ===
find_program(NVCC_EXECUTABLE nvcc HINTS "${CUDAToolkit_BIN_DIR}")
if(NOT NVCC_EXECUTABLE)
  message(FATAL_ERROR "nvcc executable not found in CUDA Toolkit bin directory.")
endif()

set(KERNELS_CU "${SRC_DFTTEST2_DIR}/cuda_source/kernels.cu")

# GPU architectures baked into the AOT fatbin. CUDA 12 includes Pascal and Volta,
# which are not supported by CUDA 13. Keep this derived from the toolkit so both
# dedicated cu12 and shared workflows use the correct architecture set.
if(CUDAToolkit_VERSION_MAJOR LESS 13)
  set(DFTTEST2_CUDA_GENCODE
      "-gencode" "arch=compute_61,code=sm_61"
      "-gencode" "arch=compute_70,code=sm_70"
      "-gencode" "arch=compute_75,code=sm_75"
      "-gencode" "arch=compute_86,code=sm_86"
      "-gencode" "arch=compute_89,code=sm_89"
      "-gencode" "arch=compute_75,code=compute_75"
  )
else()
  set(DFTTEST2_CUDA_GENCODE
      "-gencode" "arch=compute_75,code=sm_75"
      "-gencode" "arch=compute_80,code=sm_80"
      "-gencode" "arch=compute_86,code=sm_86"
      "-gencode" "arch=compute_89,code=sm_89"
      "-gencode" "arch=compute_90,code=sm_90"
      "-gencode" "arch=compute_120,code=sm_120"
      "-gencode" "arch=compute_75,code=compute_75"
  )
endif()

set(FATBIN_OUT "${CMAKE_CURRENT_BINARY_DIR}/kernels.fatbin")
set(FATBIN_HEADER "${CMAKE_CURRENT_BINARY_DIR}/kernels_fatbin.h")

find_package(Python3 COMPONENTS Interpreter REQUIRED)

add_custom_command(
  OUTPUT "${FATBIN_HEADER}"
  COMMAND "${NVCC_EXECUTABLE}"
          -fatbin
          -O3
          --use_fast_math
          --threads 0
          ${DFTTEST2_CUDA_GENCODE}
          "${KERNELS_CU}"
          -o "${FATBIN_OUT}"
  COMMAND "${Python3_EXECUTABLE}"
          "${CMAKE_CURRENT_SOURCE_DIR}/bin2c.py"
          "${FATBIN_OUT}"
          "${FATBIN_HEADER}"
          "kernels_fatbin"
  DEPENDS "${KERNELS_CU}"
  COMMENT "Compiling AOT CUDA kernels to Fatbin and embedding header..."
)

add_custom_target(generate_kernels_fatbin DEPENDS "${FATBIN_HEADER}")

# === Target Definition & Configuration ===
add_library(dfttest2_cuda MODULE "${PATCHED_WIN32}" "${SRC_DFTTEST2_DIR}/cuda_source/source.cpp")
add_dependencies(dfttest2_cuda generate_kernels_fatbin)

target_include_directories(
  dfttest2_cuda
  PRIVATE "${VAPOURSYNTH_INCLUDE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}" "${SRC_DFTTEST2_DIR}"
)

if(NOT PROJECT_VERSION_MAJOR)
  set(PROJECT_VERSION_MAJOR 1)
endif()
if(NOT PROJECT_VERSION_MINOR)
  set(PROJECT_VERSION_MINOR 0)
endif()

target_compile_definitions(
  dfttest2_cuda
  PRIVATE
    PLUGIN_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
    PLUGIN_VERSION_MINOR=${PROJECT_VERSION_MINOR}
    PLUGIN_VERSION_STRING="v${PROJECT_VERSION}"
)

target_link_libraries(dfttest2_cuda PRIVATE CUDA::cuda_driver CUDA::cufft)

if(MSVC)
  target_link_options(dfttest2_cuda PRIVATE "delayimp.lib" "/DELAYLOAD:${CUFFTT_DELAYLOAD_DLL}")
endif()

# Hide static and internal symbols to avoid conflicts with dynamically loaded CUDA libraries
if(UNIX)
  set_target_properties(dfttest2_cuda PROPERTIES CXX_VISIBILITY_PRESET hidden VISIBILITY_INLINES_HIDDEN ON)
  # Extract CUDA major version (e.g. "12.9.2" -> 12) to build the correct
  # nvidia PyPI runtime library path.
  string(REGEX MATCH
         "^([0-9]+)"
         _CUDA_MAJOR
         "${CUDAToolkit_VERSION}"
  )
  set_target_properties(dfttest2_cuda PROPERTIES INSTALL_RPATH "$ORIGIN;$ORIGIN/../../../nvidia/cu${_CUDA_MAJOR}/lib")
endif()

add_custom_target(build_cuda ALL DEPENDS dfttest2_cuda)

# === Link Libraries Setup ===
if(UNIX)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E create_symlink "${CUDAToolkit_LIBRARY_DIR}/stubs/libcuda.so"
      "${CMAKE_CURRENT_BINARY_DIR}/libcuda.so.1"
  )

  target_link_directories(dfttest2_cuda PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
  target_link_libraries(dfttest2_cuda PRIVATE :libcuda.so.1)
  target_link_options(dfttest2_cuda PRIVATE "-Wl,--exclude-libs,ALL")
endif()

# === Packaging & Installation ===
install(TARGETS dfttest2_cuda LIBRARY DESTINATION .)

if(WIN32)
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\ndfttest2_cuda\n")
else()
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nlibdfttest2_cuda\n")
endif()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" DESTINATION .)
