# AArch64-specific OpenVINO cache variables.

# Disable Intel-specific hardware plugins for ARM64 platforms.
set(ENABLE_INTEL_GPU OFF CACHE BOOL "")
set(ENABLE_ONEDNN_FOR_GPU OFF CACHE BOOL "")
set(ENABLE_INTEL_NPU OFF CACHE BOOL "")
