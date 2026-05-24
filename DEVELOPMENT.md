# Development

## Build Shell

Windows builds require the Visual Studio x64 developer environment. Start a configured shell from the repository root:

```powershell
just dev-shell
```

## Submodules

This repository vendors various dependencies as Git submodules.

Use these commands from the repository root:

```powershell
# Initialize or reset submodules to the commits tracked by this repo.
git submodule update --init --recursive

# Show each submodule's current commit and local status.
just substatus

# Native Git status output.
git submodule status

# Update every submodule to the remote branch configured in .gitmodules.
git submodule update --remote --recursive

# Update one submodule.
git submodule update --remote bm3dcuda/bm3dcpu/vapoursynth

# List tags for one submodule.
git -C bm3dcuda/bm3dcpu/vapoursynth tag

# Nuclear submodules reset
git submodule foreach --recursive git reset --hard
```

To pin a submodule to a tag:

```powershell
git -C bm3dcuda/bm3dcpu/vapoursynth fetch --tags
git -C bm3dcuda/bm3dcpu/vapoursynth tag
git -C bm3dcuda/bm3dcpu/vapoursynth checkout R57

git add bm3dcuda/bm3dcpu/vapoursynth
git commit -m "chore: update vapoursynth submodule to R57"
```

### Adding a Submodule

```powershell
& .\scripts\Add-Submodule.ps1 https://github.com/onnx/onnx.git vsmlrt/ncnn/onnx v1.19.0
```

### Removing a Submodule

```powershell
& .\scripts\Remove-Submodule.ps1 path/to/submodule
```

# Links & Reminder Notes

## NVIDIA

### Cuda Toolkit / How to install

https://developer.nvidia.com/cuda-toolkit-archive

Currently targetting RHEL 8 -> glic 2.28

### CUDA_ARCHITECTURES

~= Compute Capability (e.g. 12.0 (Blackwell) is 120 in CUDA_ARCHITECTURES)

https://developer.nvidia.com/cuda/gpus
https://en.wikipedia.org/wiki/CUDA#GPUs_supported

### Silent Installation

Subpackage name -> https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/

### RHEL8 CUDA repo index

https://developer.download.nvidia.com/compute/cuda/repos/rhel8/

## AMD

### Compatibility Matrix

https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html#gpu-compatibility

### How to install via package manager

https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/install-methods/package-manager-index.html

Currently targetting RHEL 8 -> glic 2.28

### GPU_TARGETS

https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.4.2/reference/system-requirements.html#supported-gpus
https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-gpus

### HIP Versionning

- Linux has individual version available on package managers.
- Windows has an installer AMD-Software-PRO-Edition released each quarter of the year. https://www.amd.com/en/developer/resources/rocm-hub/hip-sdk.html
  - 25.Q3-WinSvr2022 -> ROCm 6.4.2
  - 26.Q1-Win11 -> ROCm 7.1.1
