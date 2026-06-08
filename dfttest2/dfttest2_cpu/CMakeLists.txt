cmake_minimum_required(VERSION 3.22)
project(DFTTEST2_CPU_Package)

# === C++ Standard & Options ===
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(VS_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include" CACHE PATH "Path to VapourSynth headers")

if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
  set(CMAKE_DISABLE_FIND_PACKAGE_Git ON)
endif()

set(ENABLE_CUDA OFF CACHE BOOL "" FORCE)
set(ENABLE_CPU ON CACHE BOOL "" FORCE)
set(ENABLE_GCC OFF CACHE BOOL "" FORCE)
set(ENABLE_HIP OFF CACHE BOOL "" FORCE)

# === Target Definition & Configuration ===
# Add the submodule but skip its internal install rules
add_subdirectory(vs-dfttest2 EXCLUDE_FROM_ALL)

add_custom_target(build_cpu ALL DEPENDS dfttest2_cpu)

# === Packaging & Installation ===
install(TARGETS dfttest2_cpu LIBRARY DESTINATION .)
