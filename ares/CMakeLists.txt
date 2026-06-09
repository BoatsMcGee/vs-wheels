cmake_minimum_required(VERSION 3.18)
project(Ares_Package)

# === C++ Standard & Options ===
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
endif()

# === Dependencies ===
set(SUBMODULE_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ares")
file(READ "${SUBMODULE_SRC_DIR}/CMakeLists.txt" SUBMODULE_CMAKE_CONTENT)

string(REPLACE "\${CMAKE_SOURCE_DIR}" "\${SUBMODULE_SRC_DIR}" MODIFIED_CMAKE_CONTENT "${SUBMODULE_CMAKE_CONTENT}")
string(REPLACE "\${CMAKE_CURRENT_LIST_DIR}" "\${SUBMODULE_SRC_DIR}" MODIFIED_CMAKE_CONTENT "${MODIFIED_CMAKE_CONTENT}")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/ares_generated/CMakeLists.txt" "${MODIFIED_CMAKE_CONTENT}")

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# === Target Definition & Configuration ===
add_subdirectory("${CMAKE_CURRENT_BINARY_DIR}/ares_generated" "${CMAKE_CURRENT_BINARY_DIR}/ares_build" EXCLUDE_FROM_ALL)

# The upstream CMakeLists adds -static for all non-Windows GCC/Clang builds
# (including inside generator expressions), which is incompatible with building
# a shared object (.so). Strip "-static" from the raw property string.
if(NOT WIN32)
  get_target_property(_ares_link_opts AudioResample LINK_OPTIONS)
  if(_ares_link_opts)
    string(REPLACE ";-static;" ";" _ares_link_opts "${_ares_link_opts}")
    string(REGEX REPLACE "-static[ \t]+" "" _ares_link_opts "${_ares_link_opts}")
    set_target_properties(AudioResample PROPERTIES LINK_OPTIONS "${_ares_link_opts}")
  endif()
endif()

add_custom_target(build_ares ALL DEPENDS AudioResample)

# === Packaging & Installation ===
install(TARGETS AudioResample RUNTIME DESTINATION . LIBRARY DESTINATION .)
