# VSWheels

VSWheels provides pre-built wheels for various VapourSynth plugins.

PEP 503-compliant Python package index URL: [https://jaded-encoding-thaumaturgy.github.io/vs-wheels/](https://jaded-encoding-thaumaturgy.github.io/vs-wheels/)

## Installation

If downloading from the vs-wheels index:

- Using uv

  ```bash
  uv add --index https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple <package-name>
  ```

- Using pip

  ```bash
  pip install <package-name> --extra-index-url https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple
  ```

## Configuration

To avoid specifying the index URL manually, you can configure your tools to include the `vs-wheels` index by default.

### pip

Add the repository as an `extra-index-url` in your [configuration file](https://pip.pypa.io/en/stable/topics/configuration/#location).

```ini
[global]
extra-index-url = https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple
```

### uv

`uv` provides multiple methods for configuring index URLs.

- [Configuration files](https://docs.astral.sh/uv/concepts/configuration-files/).
- [Pinning a package to an index](https://docs.astral.sh/uv/concepts/indexes/#pinning-a-package-to-an-index).

#### Project Configuration

- **pyproject.toml**

  ```toml
  [[tool.uv.index]]
  name = "vs-wheels"
  url = "https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple"
  ```

- **uv.toml**

  ```toml
  [[index]]
  name = "vs-wheels"
  url = "https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple"
  ```

#### User Configuration (Global)

To use the index across all your projects, add it to your user-level `uv.toml`.

- **Windows:** `%APPDATA%\uv\uv.toml`
- **Linux/macOS:** `~/.config/uv/uv.toml`

```toml
[[index]]
name = "vs-wheels"
url = "https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple"
```

#### System-wide Configuration

To use the index system-wide, add it to your system-level `uv.toml`.

```toml
[[index]]
name = "vs-wheels"
url = "https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple"
```

#### Environment Variables

Or as environment variables for quick configuration or in CI/CD pipelines.

```bash
# Unix-like
export UV_INDEX="https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple"
```

```powershell
# PowerShell
$env:UV_INDEX = "https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple"
```

## Available Packages

### **BM3DCPU**

Available on [PyPI](https://pypi.org/project/vapoursynth-bm3dcpu/).

- **2.16**: Yanked.
- **2.16.1**: Yanked.
- **2.16.2**: Yanked.
- **2.16.3**: Yanked.
- **2.16.4**: Matches upstream R2.16. Requires VapourSynth R75.

---

### **BM3DCUDA**

Available on [PyPI](https://pypi.org/project/vapoursynth-bm3dcuda/).

- **2.16**: Matches upstream release R2.16.
  - **Windows**: Compiled with CUDA 13.0.1 and Visual Studio 2022.
  - **Linux**: Compiled with CUDA 12.8.
- **2.17.dev1**:
  - **Windows**: Compiled with CUDA 13.2.1 and Visual Studio 2026.
  - **Linux**: Compiled with CUDA 13.2.

---

### **BM3DHIP**

Available on [PyPI](https://pypi.org/project/vapoursynth-bm3dhip/).

- **2.16**: Matches upstream release R2.16.
  - **Windows**: Compiled with HIP 6.4.2 and Visual Studio 2022.
  - **Linux**: Compiled with HIP 7.0.
- **2.17.dev1**:
  - **Windows**: Compiled with HIP 7.1.1 and Visual Studio 2026.
  - **Linux**: Compiled with HIP 7.2.2.

---

### **DFTTEST2**

Available on [PyPI](https://pypi.org/project/dfttest2/).

This is the meta-package providing the Python interface and backend dependencies via extras to simplify installation.

- **10**: Matches upstream release v10

More information [here](https://github.com/Jaded-Encoding-Thaumaturgy/vs-wheels/blob/master/dfttest2/dfttest2/README.md).

### **DFTTEST2_GCC**

Available on [PyPI](https://pypi.org/project/vapoursynth-dfttest2-gcc/).

- **10**: Matches upstream release v10

  Available on all platforms.

---

### **DFTTEST2_CPU**

Available on [PyPI](https://pypi.org/project/vapoursynth-dfttest2-cpu/).

- **10**: Matches upstream release v10

---

### **DFTTEST2_NVRTC**

Available on [PyPI](https://pypi.org/project/vapoursynth-dfttest2-nvrtc/).

- **10**: Matches upstream release v10
  - **Windows**: Compiled with CUDA 13.0.1 and Visual Studio 2022.
  - **Linux**: Compiled with CUDA 13.0.
- **11.dev1**:
  - **Windows**: Compiled with CUDA 13.2.1 and Visual Studio 2026.
  - **Linux**: Compiled with CUDA 13.2.

---

### **DFTTEST2_CUDA**

Wheels are available on [vs-wheels index](https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple/vapoursynth-dfttest2-cuda/index.html).

```bash
pip install vapoursynth-dfttest2-cuda --extra-index-url https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple
```

Sdist is available on [PyPI](https://pypi.org/project/vapoursynth-dfttest2-cuda/).

- **10** / **10.post1**: Matches upstream release v10
  - **Windows**: Compiled with CUDA 13.0.1 and Visual Studio 2022.
  - **Linux**: Compiled with CUDA 13.0.
- **11.dev1**:
  - **Windows**: Compiled with CUDA 13.2.1 and Visual Studio 2026.
  - **Linux**: Compiled with CUDA 13.2.

---

### **DFTTEST2_HIP**

Available on [PyPI](https://pypi.org/project/vapoursynth-dfttest2-hip).

- **10**:
  - **Windows**: Compiled with HIP 7.1.1 and Visual Studio 2026.
  - **Linux**: Compiled with HIP 7.0.
- **11.dev1**:
  - **Windows**: Compiled with HIP 7.1.1 and Visual Studio 2026.
  - **Linux**: Compiled with HIP 7.2.2.

---

### **DFTTEST2_HIPRTC**

Available on [PyPI](https://pypi.org/project/vapoursynth-dfttest2-hiprtc).

- **10**:
  - **Windows**: Compiled with HIP 7.1.1 and Visual Studio 2026.
  - **Linux**: Compiled with HIP 7.0.
- **11.dev1**:
  - **Windows**: Compiled with HIP 7.1.1 and Visual Studio 2026.
  - **Linux**: Compiled with HIP 7.2.2.

---

### **FFMS2**

Available on [vs-wheels index](https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple/vapoursynth-ffms2/index.html) for Windows, macOS and Linux (glibc x86_64, aarch64 and musl x86_64)

```bash
pip install vapoursynth-ffms2 --extra-index-url https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple
```

- **5.2.1**: Compiled with **F**ast **F**orward **M**oving **P**icture **E**xperts **G**roup **8.1** from the vcpkg 2026.04.27 Release.
  - **Windows**: Compiled with Visual Studio 2026

  Matches upstream [ffms2@master#3af2ef2ae47bc30b64597c9e419e5b19c4bda7d8](https://github.com/FFMS/ffms2/commit/3af2ef2ae47bc30b64597c9e419e5b19c4bda7d8)

---

### **FMTCONV / FMTC**

Available on [vs-wheels index](https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple/vapoursynth-fmtconv/index.html) and on all platforms.

```bash
pip install vapoursynth-fmtconv --extra-index-url https://jaded-encoding-thaumaturgy.github.io/vs-wheels/simple
```

- **31**: Matches upstream release R31.
  - **Windows**: Compiled with Visual Studio 2026.

---

### **VS-MLRT**
