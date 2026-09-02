#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
BUILD_DIR="${SCRIPT_DIR}/.build"
OUTPUT="${BUILD_DIR}/aerospace-borders-core"
CONTROLLER="${BUILD_DIR}/aerospace-borders"
SWIFTC="/usr/bin/swiftc"

mkdir -p "$BUILD_DIR"

"$SWIFTC" \
  -O \
  -whole-module-optimization \
  -F /System/Library/PrivateFrameworks \
  -framework AppKit \
  -framework QuartzCore \
  -framework SkyLight \
  -o "$OUTPUT" \
  "${SCRIPT_DIR}/main.swift"

cp "${SCRIPT_DIR}/aerospace-borders" "$CONTROLLER"
chmod +x "$CONTROLLER"

printf 'Built %s\n' "$CONTROLLER"
