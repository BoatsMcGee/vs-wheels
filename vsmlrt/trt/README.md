# VapourSynth-MLRT-TRT

This package contains the TensorRT backend implementation of the [vs-mlrt](https://github.com/AmusementClub/vs-mlrt) plugin.

## Installation

```bash
pip install vapoursynth-mlrt-trt --extra-index-url https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple
```

## Building from source

### Requirements

- **C++ Compiler**: C++20 compatible (e.g. MSVC 2019+, GCC, Clang)
- **Dependencies**:
  - `CUDAToolkit`
  - `TensorRT` SDK (including runtime and plugins library)
- **Environment Variables**:
  - `TENSORRT_HOME`: Path to the TensorRT installation directory (must contain `include`, `lib`, and `bin`).

### Compilation

Set the `TENSORRT_HOME` environment variable before running the build:

```powershell
$env:TENSORRT_HOME="C:\Path\To\TensorRT"

uv build --package vapoursynth-mlrt-trt
```

On Linux:

```bash
export TENSORRT_HOME="/path/to/TensorRT"

uv build --package vapoursynth-mlrt-trt
```

---

Detailed parameter information from the parent project follows.

---
