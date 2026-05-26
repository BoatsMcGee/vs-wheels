# VapourSynth-MLRT-TRT-RTX

This package contains the TensorRT-based for RTX GPU inference backend implementation of the [vs-mlrt](https://github.com/AmusementClub/vs-mlrt) plugin.

## Installation

```bash
pip install vapoursynth-mlrt-trt-rtx
```

## Building from source

### Requirements

- **C++ Compiler**: C++20 compatible (e.g. MSVC 2019+, GCC, Clang)
- **Dependencies**:
  - `CUDAToolkit`
  - `TensorRT-RTX` SDK
- **Environment Variables**:
  - `TENSORRT_RTX_HOME`: Path to the TensorRT-RTX installation directory (must contain `include`, `lib`, and `bin`).

### Compilation

Set the `TENSORRT_RTX_HOME` environment variable before running the build:

```powershell
$env:TENSORRT_RTX_HOME="C:\Path\To\TensorRT-RTX"

uv build --package vapoursynth-mlrt-trt-rtx
```

On Linux:

```bash
export TENSORRT_RTX_HOME="/path/to/TensorRT-RTX"

uv build --package vapoursynth-mlrt-trt-rtx
```

---

Detailed parameter information from the parent project follows.

---
