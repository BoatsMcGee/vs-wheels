# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "tomli-w>=1.2.0",
# ]
# ///

import sys
import tomllib
from pathlib import Path

import tomli_w


def main(pyproject: Path) -> None:
    data = tomllib.loads(pyproject.read_text(encoding="utf-8"))
    data["project"]["name"] += "-cuda"
    data["project"]["description"] += " with CUDA support"
    data["tool"]["scikit-build"]["wheel"]["install-dir"] += "-cuda"

    for override in data["tool"]["scikit-build"]["overrides"]:
        if override["if"]["platform-system"] in ["win32", "linux"]:
            override["cmake"]["define"]["ENABLE_CUDA"] = "ON"

    pyproject.write_text(tomli_w.dumps(data), encoding="utf-8")


if __name__ == "__main__":
    main(Path(sys.argv[1]))
