cmake_minimum_required(VERSION 3.22)
project(DFTTEST2_CUDA_Package)

# Define the include path relative to this wrapper
set(VS_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include" CACHE PATH "Path to VapourSynth headers")

# Fix version detection
if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
  set(CMAKE_DISABLE_FIND_PACKAGE_Git ON)
endif()

set(ENABLE_CUDA ON CACHE BOOL "" FORCE)
set(USE_NVRTC_STATIC ON CACHE BOOL "" FORCE)
set(ENABLE_CPU OFF CACHE BOOL "" FORCE)
set(ENABLE_GCC OFF CACHE BOOL "" FORCE)
set(ENABLE_HIP OFF CACHE BOOL "" FORCE)

# Add the submodule but skip its internal install rules
add_subdirectory(vs-dfttest2 EXCLUDE_FROM_ALL)

# Post-process the submodule targets to fix Linux driver initialization
if(UNIX)
  find_package(CUDAToolkit REQUIRED)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E create_symlink "${CUDAToolkit_LIBRARY_DIR}/stubs/libcuda.so"
      "${CMAKE_CURRENT_BINARY_DIR}/libcuda.so.1"
  )

  target_link_directories(dfttest2_cuda PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
  target_link_libraries(dfttest2_cuda PRIVATE :libcuda.so.1)
endif()

# Link nvJitLink_static for CUDA 12+ (needed when USE_NVRTC_STATIC is ON)
find_package(CUDAToolkit REQUIRED)
target_link_directories(dfttest2_cuda PRIVATE "${CUDAToolkit_LIBRARY_DIR}")
target_link_libraries(dfttest2_cuda PRIVATE nvJitLink_static nvptxcompiler_static)

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


if(WIN32 AND ENABLE_CUDA)
  find_package(CUDAToolkit QUIET)
  file(GLOB CUFFT_DLL "${CUDAToolkit_BIN_DIR}/x64/cufft64_*.dll")

  if(CUFFT_DLL)
    message(STATUS "Found cuFFT DLL: ${CUFFT_DLL}")
    install(FILES ${CUFFT_DLL} DESTINATION vsmlrt-cuda)
  else()
    message(WARNING "No cuFFT DLL found in ${CUDAToolkit_BIN_DIR}/x64")
  endif()
endif()

add_custom_target(build_cuda ALL DEPENDS dfttest2_cuda)

if(WIN32 AND CUFFT_DLL)
  add_custom_command(
    TARGET build_cuda
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:dfttest2_cuda>/vsmlrt-cuda
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CUFFT_DLL} $<TARGET_FILE_DIR:dfttest2_cuda>/vsmlrt-cuda
    COMMENT "Copying cuFFT DLL to vsmlrt-cuda subdirectory"
  )
endif()

install(TARGETS dfttest2_cuda LIBRARY DESTINATION .)

if(WIN32)
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\ndfttest2_cuda\n")
else()
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nlibdfttest2_cuda\n")
endif()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" DESTINATION .)
