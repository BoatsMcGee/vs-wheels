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
