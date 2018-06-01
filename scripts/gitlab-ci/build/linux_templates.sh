#!/bin/bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

export DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../_common.sh"

# Use recent GCC provided by the Ubuntu Toolchain PPA
export CC="gcc-8"
export CXX="g++-8"

# Build Linux export templates
# Link libpng statically to avoid dependency issues
for target in "release_debug" "release"; do
  for mono in "yes" "no"; do
    scons platform=x11 \
          tools=no \
          target=$target \
          module_mono_enabled=$mono \
          builtin_libpng=yes \
          use_static_cpp=yes \
          LINKFLAGS="-fuse-ld=gold" \
          $SCONS_FLAGS
  done
done

# Strip binaries of any debug symbols to decrease file size
strip bin/godot.*

# Create Linux export templates TPZ
# Pretend 64-bit binaries are 32-bit binaries for now, to avoid errors
# in the editor's Export dialog
mkdir -p "templates/"
cp "$CI_PROJECT_DIR/resources/version.txt" "templates/version.txt"
cp "bin/godot.x11.opt.debug.64" "templates/linux_x11_64_debug"
mv "bin/godot.x11.opt.debug.64" "templates/linux_x11_32_debug"
cp "bin/godot.x11.opt.64" "templates/linux_x11_64_release"
mv "bin/godot.x11.opt.64" "templates/linux_x11_32_release"

zip -r9 "$ARTIFACTS_DIR/templates/godot-templates-linux-nightly.tpz" "templates/"

# Create Linux Mono export templates TPZ
rm -rf "templates/"
mkdir -p "templates/"
cp "$CI_PROJECT_DIR/resources/version.mono.txt" "templates/version.txt"
cp "bin/godot.x11.opt.debug.64.mono" "templates/linux_x11_64_debug"
mv "bin/godot.x11.opt.debug.64.mono" "templates/linux_x11_32_debug"
cp "bin/godot.x11.opt.64.mono" "templates/linux_x11_64_release"
mv "bin/godot.x11.opt.64.mono" "templates/linux_x11_32_release"

zip -r9 "$ARTIFACTS_DIR/templates/godot-templates-linux-nightly-mono.tpz" "templates/"
