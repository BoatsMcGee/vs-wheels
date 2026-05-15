# macOS-specific NCNN cache variables.
#
# NOTE: Vulkan_LIBRARY and OpenMP_ROOT are set on the command line
# because they depend on runtime paths ($VULKAN_SDK, brew --prefix).

set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")
set(CMAKE_POLICY_DEFAULT_CMP0074 NEW CACHE STRING "")
