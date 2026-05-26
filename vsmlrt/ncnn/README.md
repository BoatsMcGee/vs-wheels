# VapourSynth-MLRT-NCNN

This package contains the NCNN backend implementation of the [vs-mlrt](https://github.com/AmusementClub/vs-mlrt) plugin.

## Installation

```bash
pip install vapoursynth-mlrt-ncnn
```

## Building from source

### Requirements
- **C++ Compiler**: C++20 compatible (e.g. MSVC 2019+, GCC, Clang)
- **Dependencies**:
  - `ncnn` (Vulkan support enabled)
  - `Protobuf`
  - `ONNX`
  - `Vulkan` SDK
- **Platforms**: Windows, Linux, macOS (uses Metal on macOS)

### Compilation

Ensure all required dependencies (ONNX, NCNN, Vulkan SDK, Protobuf) are discoverable by CMake (e.g., via `CMAKE_PREFIX_PATH` or system package manager).

```powershell
uv build --package vapoursynth-mlrt-ncnn
```

---

Detailed parameter information from the parent project follows.

---
