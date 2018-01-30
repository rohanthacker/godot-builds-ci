#!/bin/bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

export DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../_common.sh"

# Build iOS export templates
# Compile only 64-bit ARM binaries, as all Apple devices supporting
# OpenGL ES 3.0 have 64-bit ARM processors anyway
# An empty `data.pck` file must be included in the export template ZIP as well
scons platform=iphone arch=arm64 tools=no target=release_debug $OPTIONS
scons platform=iphone arch=arm64 tools=no target=release $OPTIONS

# Create iOS export templates ZIP archive
mkdir -p "templates/"
mv "bin/libgodot.iphone.opt.debug.arm64.a" "libgodot.iphone.debug.fat.a"
mv "bin/libgodot.iphone.opt.arm64.a" "libgodot.iphone.release.fat.a"
touch "data.pck"
zip -9 "templates/iphone.zip" "libgodot.iphone.debug.fat.a" "libgodot.iphone.release.fat.a" "data.pck"
zip -r9 "$ARTIFACTS_DIR/templates/godot-templates-ios.tpz" "templates/"