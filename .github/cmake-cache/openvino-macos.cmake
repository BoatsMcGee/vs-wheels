# macOS-specific OpenVINO cache variables.

set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "")
set(CMAKE_POLICY_VERSION_MINIMUM 3.5 CACHE STRING "")

# Use Homebrew's TBB instead of building from source.
# The subproject build produces dylibs with malformed __LINKEDIT segments
# that Xcode's install_name_tool can't process, breaking wheel delocating.
set(ENABLE_SYSTEM_TBB ON CACHE BOOL "")
