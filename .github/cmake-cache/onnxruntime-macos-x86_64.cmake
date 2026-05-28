# macOS x86_64-specific ONNX Runtime cache variables.

set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "")
set(onnxruntime_ENABLE_CPU_FP16_OPS OFF CACHE BOOL "")
set(onnxruntime_USE_AVX ON CACHE BOOL "")
