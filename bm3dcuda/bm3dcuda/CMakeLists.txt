cmake_minimum_required(VERSION 3.20)
project(BM3DCUDA_Package)

# Define the include path relative to this wrapper
set(
  VAPOURSYNTH_INCLUDE_DIRECTORY
  "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include"
  CACHE PATH
  "Path to VapourSynth headers"
)

# Add the submodule
add_subdirectory(VapourSynth-BM3DCUDA)

# Post-process the submodule targets to fix Linux driver initialization
if(UNIX)
  find_package(CUDAToolkit REQUIRED)

  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E create_symlink "${CUDAToolkit_LIBRARY_DIR}/stubs/libcuda.so"
      "${CMAKE_CURRENT_BINARY_DIR}/libcuda.so.1"
  )

  target_link_directories(bm3dcuda_rtc PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
  target_link_libraries(bm3dcuda_rtc PRIVATE :libcuda.so.1)
endif()

# Link nvJitLink_static for CUDA 12+ (needed when USE_NVRTC_STATIC is ON)
find_package(CUDAToolkit REQUIRED)
if(TARGET bm3dcuda_rtc)
  target_link_directories(bm3dcuda_rtc PRIVATE "${CUDAToolkit_LIBRARY_DIR}")
  target_link_libraries(bm3dcuda_rtc PRIVATE nvJitLink_static nvptxcompiler_static)
endif()

# Hide static and internal symbols to avoid conflicts with dynamically loaded CUDA libraries
if(UNIX)
  set_target_properties(dfttest2_cuda PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
  )
  if(NOT APPLE)
    target_link_options(dfttest2_cuda PRIVATE "-Wl,--exclude-libs,ALL")
  endif()
endif()
