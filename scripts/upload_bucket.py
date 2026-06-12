# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "huggingface_hub>=0.28.0",
# ]
# ///
"""
Sync local package distributions to HuggingFace Storage Bucket.
"""

import os
import sys

from huggingface_hub import sync_bucket


def main() -> None:
    local_path = sys.argv[1] if len(sys.argv) > 1 else "dist"
    bucket_name = sys.argv[2] if len(sys.argv) > 2 else os.environ.get("HF_BUCKET", "Ichunjo/wheel-storage")

    bucket_uri = f"hf://buckets/{bucket_name}"
    print(f"Syncing {local_path} -> {bucket_uri}...")
    sync_bucket(source=local_path, dest=bucket_uri)
    print("Sync completed successfully.")


if __name__ == "__main__":
    main()
