cmake_minimum_required(VERSION 3.22)
project(DFTTEST2_GCC_Package)

# === C++ Standard & Options ===
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(VS_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include" CACHE PATH "Path to VapourSynth headers")

if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
  set(CMAKE_DISABLE_FIND_PACKAGE_Git ON)
endif()

set(ENABLE_CUDA OFF CACHE BOOL "" FORCE)
set(ENABLE_CPU OFF CACHE BOOL "" FORCE)
set(ENABLE_GCC ON CACHE BOOL "" FORCE)
set(ENABLE_HIP OFF CACHE BOOL "" FORCE)

# === Dependencies ===
find_package(Threads REQUIRED)

# === Target Definition & Configuration ===
# Add the submodule but skip its internal install rules
add_subdirectory(vs-dfttest2 EXCLUDE_FROM_ALL)

add_custom_target(build_gcc ALL DEPENDS dfttest2_gcc)

# === Link Libraries Setup ===
target_link_libraries(dfttest2_gcc PRIVATE Threads::Threads)

# === Packaging & Installation ===
install(TARGETS dfttest2_gcc LIBRARY DESTINATION .)
