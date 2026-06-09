cmake_minimum_required(VERSION 3.18)
project(ATools_Package)

# === C++ Standard & Options ===
if(SKBUILD_PROJECT_VERSION)
  set(VCS_TAG "v${SKBUILD_PROJECT_VERSION}" CACHE STRING "Version from scikit-build-core")
endif()

# === Dependencies ===
set(SUBMODULE_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/atools")

file(READ "${SUBMODULE_SRC_DIR}/CMakeLists.txt" SUBMODULE_CMAKE_CONTENT)
string(REPLACE "\${CMAKE_SOURCE_DIR}" "\${SUBMODULE_SRC_DIR}" MODIFIED_CMAKE_CONTENT "${SUBMODULE_CMAKE_CONTENT}")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/atools_generated/CMakeLists.txt" "${MODIFIED_CMAKE_CONTENT}")

# === Patch Submodule Type Mismatch ===
if(EXISTS "${SUBMODULE_SRC_DIR}/src/crossfade.cpp")
  file(READ "${SUBMODULE_SRC_DIR}/src/crossfade.cpp" CROSSFADE_CONTENT)
  if(CROSSFADE_CONTENT MATCHES "std::max\\(fadeSamples, 0LL\\)")
    string(
      REPLACE "std::max(fadeSamples, 0LL)"
      "std::max<int64_t>(fadeSamples, 0)"
      MODIFIED_CROSSFADE
      "${CROSSFADE_CONTENT}"
    )
    file(WRITE "${SUBMODULE_SRC_DIR}/src/crossfade.cpp" "${MODIFIED_CROSSFADE}")
  endif()
endif()

# === Target Definition & Configuration ===
add_subdirectory(
  "${CMAKE_CURRENT_BINARY_DIR}/atools_generated"
  "${CMAKE_CURRENT_BINARY_DIR}/atools_build"
  EXCLUDE_FROM_ALL
)
add_custom_target(build_atools ALL DEPENDS AudioTools)

# === Packaging & Installation ===
install(TARGETS AudioTools RUNTIME DESTINATION . LIBRARY DESTINATION .)
