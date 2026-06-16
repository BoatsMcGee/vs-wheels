# VapourSynth-MLRT-ORT

This package contains the ONNX Runtime backend implementation of the [vs-mlrt](https://github.com/AmusementClub/vs-mlrt) plugin.

## Installation

To install the standard CPU/DirectML/CoreML package:

```bash
pip install vapoursynth-mlrt-ort
```

To install the CUDA-enabled package:

```bash
pip install vapoursynth-mlrt-ort-cuda
```

## Building from source

### Requirements

- **C++ Compiler**: C++20 compatible (e.g. MSVC 2019+, GCC, Clang)
- **Dependencies**:
  - `onnxruntime` (ONNX Runtime SDK)
  - `ONNX`
  - `Protobuf`
- **Optional Backend Dependencies**:
  - **DirectML** (Windows): Requires DirectML SDK. Define the `DML_DIR` environment/CMake variable to point to the SDK directory.
  - **CUDA**: Requires `CUDAToolkit` and `cuDNN` SDKs. Ensure `CUDA_PATH`, `CUDNN_PATH` / `CUDNN_HOME` are set correctly.

### Compilation

By default, the package builds the CPU backend (with CoreML on macOS and optionally DirectML on Windows):

```powershell
uv build --package vapoursynth-mlrt-ort
```

To build the CUDA-enabled version, the package definition must first be updated using the helper script:

```powershell
# Update pyproject.toml package configuration to target CUDA
uv run --script scripts/cuda_pyproject.py pyproject.toml

# Compile the CUDA package
uv build --package vapoursynth-mlrt-ort-cuda
```

---

Detailed parameter information from the parent project follows.

---
