# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "tomli-w>=1.2.0",
# ]
# ///
"""
Update pyproject.toml for CUDA build.

Usage:
    cuda_pyproject.py <pyproject-path> [cuda-major-version]

If cuda-major-version is not provided, it is derived from the environment variable
CUDA_VERSION, or from CUDA_WINDOWS_VERSION/CUDA_LINUX_VERSION based on the current
platform (sys.platform), defaulting to 13.

All nvidia-* dependency version constraints are derived from the CUDA major version.
"""

import os
import sys
import tomllib
from pathlib import Path

import tomli_w


def _detect_cuda_major() -> int:
    """Detect CUDA major version from environment or default to 13."""
    # First check for an explicit CUDA_VERSION
    val = os.environ.get("CUDA_VERSION", "")
    if val:
        try:
            return int(val.split(".")[0])
        except (ValueError, IndexError):
            pass

    # Then check platform-specific version
    if sys.platform == "win32":
        val = os.environ.get("CUDA_WINDOWS_VERSION", "")
    else:
        val = os.environ.get("CUDA_LINUX_VERSION", "")
    if val:
        try:
            return int(val.split(".")[0])
        except (ValueError, IndexError):
            pass

    return 13


def main(pyproject: Path, cuda_major: int | None = None) -> None:
    if cuda_major is None:
        cuda_major = _detect_cuda_major()

    data = tomllib.loads(pyproject.read_text(encoding="utf-8"))
    data["project"]["name"] += "-cuda"
    data["project"]["description"] += " with CUDA support"
    data["tool"]["scikit-build"]["wheel"]["install-dir"] += "-cuda"

    cu_suffix = f"cu{cuda_major}"
    cuda_upper = cuda_major + 1
    cufft_major = cuda_major
    cufft_upper = cufft_major + 1
    curand_major = 10 if cuda_major >= 13 else 10
    curand_upper = curand_major + 1

    data["project"]["dependencies"].extend(
        [
            f"nvidia-cublas>={cuda_major}.0.0,<{cuda_upper}.0.0",
            f"nvidia-cuda-runtime>={cuda_major}.0.0,<{cuda_upper}.0.0",
            f"nvidia-cudnn-{cu_suffix}>=9.0.0,<10.0.0",
            f"nvidia-cufft>={cufft_major}.0.0,<{cufft_upper}.0.0",
            f"nvidia-cuda-cupti>={cuda_major}.0.0,<{cuda_upper}.0.0",
            f"nvidia-cuda-nvrtc>={cuda_major}.0.0,<{cuda_upper}.0.0",
            f"nvidia-curand>={curand_major}.0.0,<{curand_upper}.0.0",
        ]
    )

    for override in data["tool"]["scikit-build"]["overrides"]:
        if override["if"]["platform-system"] in ["win32", "linux"]:
            override["cmake"]["define"]["ENABLE_CUDA"] = "ON"

    pyproject.write_text(tomli_w.dumps(data), encoding="utf-8")


if __name__ == "__main__":
    pyproject_path = Path(sys.argv[1])
    cuda_ver = int(sys.argv[2]) if len(sys.argv) > 2 else None
    main(pyproject_path, cuda_ver)
