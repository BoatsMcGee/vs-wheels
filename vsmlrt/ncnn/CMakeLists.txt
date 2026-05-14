cmake_minimum_required(VERSION 3.22)
project(VSNCNN_Package)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ncnn REQUIRED)
find_package(Protobuf REQUIRED CONFIG)
find_package(ONNX REQUIRED)
find_package(Vulkan REQUIRED)

set(
  VAPOURSYNTH_INCLUDE_DIRECTORY
  "${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth/include"
  CACHE PATH
  "Path to VapourSynth headers"
)

add_library(vsncnn SHARED vs-mlrt/vsncnn/vs_ncnn.cpp vs-mlrt/vsncnn/onnx2ncnn.cpp vs-mlrt/common/onnx_utils.cpp)
set_target_properties(
  vsncnn
  PROPERTIES POSITION_INDEPENDENT_CODE ON CXX_EXTENSIONS OFF CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
)

target_include_directories(vsncnn PRIVATE "${VAPOURSYNTH_INCLUDE_DIRECTORY}")
target_link_libraries(vsncnn PRIVATE ncnn ONNX::onnx)
target_link_libraries(vsncnn PRIVATE Vulkan::Vulkan)

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

target_include_directories(vsncnn PUBLIC "${PROJECT_BINARY_DIR}")

if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
  set(CMAKE_DISABLE_FIND_PACKAGE_Git ON)
endif()

configure_file(vs-mlrt/vsncnn/config.h.in config.h)

install(TARGETS vsncnn LIBRARY DESTINATION . RUNTIME DESTINATION .)
