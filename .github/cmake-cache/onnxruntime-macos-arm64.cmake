# macOS arm64-specific ONNX Runtime cache variables.

set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "")
set(onnxruntime_ENABLE_CPU_FP16_OPS ON CACHE BOOL "")
