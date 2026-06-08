cmake_minimum_required(VERSION 3.20)
project(BM3DCPU_Distribution VERSION 2.6 LANGUAGES CXX)

# === C++ Standard & Options ===
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(BM3D_MULTI_TARGET "Build multiple optimized binaries for distribution" OFF)

set(VAPOURSYNTH_INCLUDE_DIRECTORY "vapoursynth/include" CACHE PATH "Path to VapourSynth headers")

# === Dependencies ===
include("${CMAKE_CURRENT_SOURCE_DIR}/Common.cmake")

# === Target Definition & Configuration ===
set(SOURCE_FILE "VapourSynth-BM3DCUDA/cpu_source/source.cpp")
set(SOURCE_DIR "VapourSynth-BM3DCUDA/cpu_source")

if(BM3D_MULTI_TARGET)
  file(READ "arch_configs.json" JSON_DATA)
  string(JSON CONFIG_COUNT LENGTH "${JSON_DATA}")
  math(EXPR CONFIG_MAX "${CONFIG_COUNT} - 1")

  foreach(I RANGE ${CONFIG_MAX})
    string(JSON CONFIG GET "${JSON_DATA}" ${I})
    string(JSON SUFFIX GET "${CONFIG}" "suffix")
    string(JSON MTUNE GET "${CONFIG}" "mtune")
    string(JSON EXTRA_FLAGS GET "${CONFIG}" "extra_flags")

    set(TARGET_NAME "bm3dcpu_${SUFFIX}")
    add_library(${TARGET_NAME} SHARED ${SOURCE_FILE})
    target_include_directories(${TARGET_NAME} PRIVATE ${VAPOURSYNTH_INCLUDE_DIRECTORY})

    apply_bm3d_compile_options(${TARGET_NAME} "${MTUNE}" "${EXTRA_FLAGS}")

    set_target_properties(${TARGET_NAME} PROPERTIES OUTPUT_NAME "bm3dcpu${SUFFIX}")
  endforeach()
else()
  add_library(bm3dcpu SHARED ${SOURCE_FILE})
  target_include_directories(bm3dcpu PRIVATE ${VAPOURSYNTH_INCLUDE_DIRECTORY})

  apply_bm3d_compile_options(bm3dcpu "native" "")
endif()

# === Packaging & Installation ===
if(BM3D_MULTI_TARGET)
  foreach(I RANGE ${CONFIG_MAX})
    string(JSON CONFIG GET "${JSON_DATA}" ${I})
    string(JSON SUFFIX GET "${CONFIG}" "suffix")
    set(TARGET_NAME "bm3dcpu_${SUFFIX}")
    install(TARGETS ${TARGET_NAME} DESTINATION .)
  endforeach()

  if(WIN32)
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nbm3dcpu\n")
  else()
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" "[VapourSynth Manifest V1]\nlibbm3dcpu\n")
  endif()
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/manifest.vs" DESTINATION .)
else()
  install(TARGETS bm3dcpu DESTINATION .)
endif()
