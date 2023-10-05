#!/bin/bash

BUILD_NAME="radroots_tool"
BUILD_CARGO_TOML="Cargo.toml"
BUILD_VERSION=""
BUILD_REPORT_PATH="./build_report.txt"
TARGET_APPLE_AARCH64="aarch64-apple-darwin"
TARGET_APPLE_AARCH64_DIR="target/${TARGET_APPLE_AARCH64}/release"

validate_main() {
    > "$BUILD_REPORT_PATH"

    if [ ! -f "$BUILD_CARGO_TOML" ]; then
        echo "Error: missing 'Cargo.toml'."
        exit 1
    fi

    BUILD_VERSION=$(grep 'version =' "$BUILD_CARGO_TOML" | awk -F '"' '{print $2}')
   
    if [ -z "$BUILD_VERSION" ]; then
        echo "Error: missing 'BUILD_VERSION'."
        exit 1
    fi
}

build_release_apple() {
    if [ -d "$TARGET_APPLE_AARCH64_DIR" ]; then
        rm -rf "$TARGET_APPLE_AARCH64_DIR";
    fi

    local tar_file_name="${BUILD_NAME}-${BUILD_VERSION}-${TARGET_APPLE_AARCH64}.tar.gz"
    local tar_file_path="$TARGET_APPLE_AARCH64_DIR/$tar_file_name"

    cargo build --release --target "$TARGET_APPLE_AARCH64"
    tar -czf "$tar_file_path" "$TARGET_APPLE_AARCH64_DIR/$BUILD_NAME"
    local build_hash="$(awk '{print $1}' <<< "$(shasum "$tar_file_path")")"

    echo "[build] $TARGET_APPLE_AARCH64 $tar_file_path $build_hash" >> "$BUILD_REPORT_PATH"
}

main() {
    validate_main
    build_release_apple
}

main

