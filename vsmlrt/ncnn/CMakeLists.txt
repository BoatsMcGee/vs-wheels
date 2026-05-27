cmake_minimum_required(VERSION 3.22)
project(VSNCNN_Package)

# === C++ Standard & Options ===
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

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
find_package(ncnn REQUIRED)
find_package(Protobuf REQUIRED CONFIG)
find_package(ONNX REQUIRED)
find_package(Vulkan REQUIRED)

# === Target Definition & Configuration ===
add_library(vsncnn SHARED vs-mlrt/vsncnn/vs_ncnn.cpp vs-mlrt/vsncnn/onnx2ncnn.cpp vs-mlrt/common/onnx_utils.cpp)

set_target_properties(
  vsncnn
  PROPERTIES POSITION_INDEPENDENT_CODE ON CXX_EXTENSIONS OFF CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
)

if(UNIX)
  if(APPLE)
    set_target_properties(vsncnn PROPERTIES INSTALL_RPATH "@loader_path")
  else()
    set_target_properties(vsncnn PROPERTIES INSTALL_RPATH "$ORIGIN")
  endif()
endif()

target_include_directories(vsncnn PRIVATE "${VAPOURSYNTH_INCLUDE_DIRECTORY}" PUBLIC "${PROJECT_BINARY_DIR}")

configure_file(vs-mlrt/vsncnn/config.h.in config.h)

# === Link Libraries Setup ===
target_link_libraries(vsncnn PRIVATE ncnn ONNX::onnx Vulkan::Vulkan)

if(APPLE)
  target_link_libraries(
    vsncnn
    PRIVATE
      "-framework Metal"
      "-framework Foundation"
      "-framework QuartzCore"
      "-framework CoreGraphics"
      "-framework IOSurface"
      "-framework AppKit"
      "-framework IOKit"
  )
endif()

# === Packaging & Installation ===
install(TARGETS vsncnn LIBRARY DESTINATION . RUNTIME DESTINATION .)
