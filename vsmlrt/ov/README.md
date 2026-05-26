# VapourSynth-MLRT-OV

This package contains the OpenVINO backend implementation of the [vs-mlrt](https://github.com/AmusementClub/vs-mlrt) plugin.

## Installation

```bash
pip install vapoursynth-mlrt-ov
```

## Building from source

### Requirements

- **C++ Compiler**: C++20 compatible (e.g. MSVC 2019+, GCC, Clang)
- **Dependencies**:
  - `OpenVINO` SDK (including OpenVINO Runtime & TBB)
  - `ONNX`
  - `Protobuf`
- **CMake Options**:
  - `WIN32_SHARED_OPENVINO` (defaults to `ON`): Build for Windows with a shared OpenVINO dynamic library. If enabled, copies OpenVINO Runtime and dependency DLLs (`tbb12.dll`, etc.) to the installation folder.

### Compilation

```powershell
uv build --package vapoursynth-mlrt-ov
```

---

Detailed parameter information from the parent project follows.

---
