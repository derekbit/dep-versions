#!/bin/bash
set -euo pipefail

MAIN_DIR=$(dirname $(dirname $(realpath $0)))

REPO_OVERRIDE="$1"
COMMIT_ID_OVERRIDE="$2"
SRC_DIR="/usr/src/liburing"
BUILD_DIR="$SRC_DIR/.build"

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Fetch repo and commit ID from versions.json, with optional overrides
LIBURING_REPO=$(jq -r '.["liburing"].repo' ${MAIN_DIR}/versions.json)
LIBURING_COMMIT_ID=$(jq -r '.["liburing"].commit' ${MAIN_DIR}/versions.json)

# Apply overrides if provided
if [[ -n "$REPO_OVERRIDE" ]]; then
    LIBURING_REPO="$REPO_OVERRIDE"
fi

if [[ -n "$COMMIT_ID_OVERRIDE" ]]; then
    LIBURING_COMMIT_ID="$COMMIT_ID_OVERRIDE"
fi

# Clone the repository
git clone "$LIBURING_REPO" "$SRC_DIR"

# Checkout the specific commit
cd "$SRC_DIR"
git checkout "$LIBURING_COMMIT_ID"

# Create and enter the build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Build and install
CFLAGS="-march=armv8-a" CXXFLAGS="-march=armv8-a" ./configure
make
make install
