#!/bin/bash

# Định nghĩa biến cho đường dẫn decompile
DECOMPILE_DIR="/media/lam/HD2Tb/wearable-project/decompile"

# Kiểm tra và tạo thư mục $DECOMPILE_DIR nếu chưa tồn tại
if [ ! -d "$DECOMPILE_DIR" ]; then
    mkdir -p "$DECOMPILE_DIR"
fi

# Copy the file decompile.csv to $DECOMPILE_DIR if it exists in the same directory as this script
if [ -f "$(dirname "$0")/decompile.csv" ]; then
    cp "$(dirname "$0")/decompile.csv" "$DECOMPILE_DIR"
fi

# Kiểm tra và tạo thư mục $DECOMPILE_DIR/java nếu chưa tồn tại
if [ ! -d "$DECOMPILE_DIR/java" ]; then
    mkdir -p "$DECOMPILE_DIR/java"
fi

# Kiểm tra và tạo thư mục $DECOMPILE_DIR/apk nếu chưa tồn tại
if [ ! -d "$DECOMPILE_DIR/apk" ]; then
    mkdir -p "$DECOMPILE_DIR/apk"
fi

# Kiểm tra và tạo thư mục $DECOMPILE_DIR/apk-done nếu chưa tồn tại
if [ ! -d "$DECOMPILE_DIR/apk-done" ]; then
    mkdir -p "$DECOMPILE_DIR/apk-done"
fi

# Kiểm tra và tạo thư mục $DECOMPILE_DIR/apk-time-out nếu chưa tồn tại
if [ ! -d "$DECOMPILE_DIR/apk-time-out" ]; then
    mkdir -p "$DECOMPILE_DIR/apk-time-out"
fi

chmod -R 777 "$DECOMPILE_DIR"  # Add chmod command at the end
chmod -R 777 "$DECOMPILE_DIR/*"  # Add chmod command at the end

echo "Directories created and permissions set successfully!"
