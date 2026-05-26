# VapourSynth-MLRT-MIGX

This package contains the MIGraphX backend implementation of the [vs-mlrt](https://github.com/AmusementClub/vs-mlrt) plugin.

## Installation

```bash
pip install vapoursynth-mlrt-migx
```

## Building from source

Only Linux x86-64 is currently supported.

### Requirements

- **C++ Compiler**: C++20 compatible (e.g. GCC, AMD Clang)
- **Dependencies**:
  - `migraphx` (MIGraphX SDK)
  - `hip` (ROCm HIP runtime)
- **Environment Variables**:
  - `ROCM_PATH`: Path to ROCm installation (defaults to `/opt/rocm` if not set)

### Compilation

```bash
# Set ROCM_PATH if not installed in default /opt/rocm
export ROCM_PATH="/opt/rocm"

uv build --package vapoursynth-mlrt-migx
```

---

Detailed parameter information from the parent project follows.

---
