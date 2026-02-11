#!/bin/sh
set -e

echo "Building all packages..."

# Create output directory
mkdir -p /tmp/packages

export PACKAGER="poteznydorsz"
export REPODEST=/tmp/packages

# Build each package
for pkg in /workspace/packages/*; do
    if [ -d "$pkg" ] && [ -f "$pkg/APKBUILD" ]; then
        echo "==> Building $(basename $pkg)..."
        cd "$pkg"
        abuild-keygen -a -i -n || true
        abuild checksum || true
        abuild -r || {
            echo "Failed to build $(basename $pkg)"
            continue
        }
    fi
done

echo "Creating repository index..."
cd /tmp/packages
for arch_dir in */; do
    if [ -d "$arch_dir" ]; then
        cd "$arch_dir"
        apk index -o APKINDEX.tar.gz *.apk
        abuild-sign -q APKINDEX.tar.gz
        cd ..
    fi
done

echo "Build complete!"
ls -lR /tmp/packages
