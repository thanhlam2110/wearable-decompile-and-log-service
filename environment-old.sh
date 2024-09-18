#!/bin/bash

# Kiểm tra và tạo thư mục /root/decompile nếu chưa tồn tại
if [ ! -d "/root/decompile" ]; then
    mkdir -p /root/decompile
fi

# Copy the file decompile.csv to /root/decompile if it exists in the same directory as this script
if [ -f "$(dirname "$0")/decompile.csv" ]; then
    cp "$(dirname "$0")/decompile.csv" /root/decompile
fi

# Kiểm tra và tạo thư mục /root/decompile/java nếu chưa tồn tại
if [ ! -d "/root/decompile/java" ]; then
    mkdir -p /root/decompile/java
fi

# Kiểm tra và tạo thư mục /root/decompile/apk nếu chưa tồn tại
if [ ! -d "/root/decompile/apk" ]; then
    mkdir -p /root/decompile/apk
fi

# Kiểm tra và tạo thư mục /root/decompile/apk-done nếu chưa tồn tại
if [ ! -d "/root/decompile/apk-done" ]; then
    mkdir -p /root/decompile/apk-done
fi

# Kiểm tra và tạo thư mục /root/decompile/apk-done nếu chưa tồn tại
if [ ! -d "/root/decompile/apk-time-out" ]; then
    mkdir -p /root/decompile/apk-time-out
fi

chmod -R 777 /root/decompile  # Add chmod command at the end
chmod -R 777 /root/decompile/*  # Add chmod command at the end

echo "Directories created and permissions set successfully!"
