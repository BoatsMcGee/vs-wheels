# Base NCNN cache variables shared across all platforms.

# The AmusementClub/ncnn fork adds:
# -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded: Static CRT (/MT) (Windows only)
# -D NCNN_ENABLE_LTO=TRUE: Link-time optimizations

set(CMAKE_BUILD_TYPE Release CACHE STRING "")
set(NCNN_VULKAN ON CACHE BOOL "")
set(NCNN_BUILD_BENCHMARK OFF CACHE BOOL "")
set(NCNN_BUILD_EXAMPLES OFF CACHE BOOL "")
set(NCNN_BUILD_TESTS OFF CACHE BOOL "")
set(NCNN_BUILD_TOOLS OFF CACHE BOOL "")
set(NCNN_ENABLE_LTO ON CACHE BOOL "")
