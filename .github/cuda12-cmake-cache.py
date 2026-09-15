# /// script
# requires-python = ">=3.12"
# ///
"""
Adjust ONNX Runtime CUDA build cache for older CUDA versions.

Usage:
    cuda12_cmake_cache.py <cmake-cache-file> [cuda-major-version]

If cuda-major-version is not provided, it is derived from the environment variable
CUDA_VERSION, or from CUDA_WINDOWS_VERSION/CUDA_LINUX_VERSION based on the current
platform (sys.platform), defaulting to 13.

On CUDA 12 the CMAKE_CUDA_ARCHITECTURES list is rewritten to:
1. Add sm_61 (Pascal/GTX 10-series) for older GPU support
2. Add sm_70 (Volta/V100) to bridge Pascal-Turing
3. Remove sm_120 (Blackwell) - not needed by the CUDA 12 audience
"""

import os
import re
import sys

CU12_ARCHS = "61-real;70-real;75-real;86-real;89-real"
CU13_ARCHS = "75-real;86-real;89-real;120-real"


def _detect_cuda_major() -> int:
    """Detect CUDA major version from environment or default to 13."""
    val = os.environ.get("CUDA_VERSION", "")
    if val:
        try:
            return int(val.split(".")[0])
        except (ValueError, IndexError):
            pass

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


def main(cache_file: str, cuda_major: int | None = None) -> None:
    if cuda_major is None:
        cuda_major = _detect_cuda_major()

    if cuda_major >= 13:
        print(f"CUDA {cuda_major}: no cmake cache changes needed")
        return

    path = os.fsdecode(cache_file)
    original = open(path, encoding="utf-8").read()
    updated = re.sub(
        r'(CMAKE_CUDA_ARCHITECTURES\s+")([^"]+)(")',
        rf"\g<1>{CU12_ARCHS}\g<3>",
        original,
    )
    if updated != original:
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(updated)
        print(f"Set CUDA {cuda_major} GPU archs to {CU12_ARCHS} in {path}")
    else:
        print(f"WARNING: CMAKE_CUDA_ARCHITECTURES not found or unchanged in {path}")


if __name__ == "__main__":
    cache_path = sys.argv[1]
    major = int(sys.argv[2]) if len(sys.argv) > 2 else None
    main(cache_path, major)
