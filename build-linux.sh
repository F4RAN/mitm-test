#!/usr/bin/env bash
# Build a single-file Linux x86_64 binary using PyInstaller inside a
# manylinux-compatible container. Output: dist/masterhttprelay
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
IMAGE="python:3.12-slim-bookworm"
NAME="masterhttprelay"

cd "$HERE"

rm -rf build dist "$NAME.spec"

docker run --rm --platform linux/amd64 \
  -v "$HERE":/src -w /src \
  "$IMAGE" \
  bash -euo pipefail -c '
    apt-get update -qq
    apt-get install -y --no-install-recommends binutils file >/dev/null
    python -m pip install --no-cache-dir --upgrade pip >/dev/null
    pip install --no-cache-dir -r requirements.txt pyinstaller >/dev/null

    pyinstaller \
      --onefile \
      --clean \
      --strip \
      --name '"$NAME"' \
      --hidden-import=cryptography \
      --hidden-import=h2 \
      --hidden-import=hpack \
      --hidden-import=hyperframe \
      main.py

    file dist/'"$NAME"'
    ls -lh dist/'"$NAME"'
  '

echo
echo "Built: $HERE/dist/$NAME"
echo "Copy this file, config.json and (optionally) ca/ to your Linux host."
