#!/bin/bash

# 定义变量，便于维护和复用
URL="https://raw.githubusercontent.com/qq5460168/666/master/dns.txt"
OUTPUT_FILE="$HOME/AD.txt"

# 下载文件到主目录并重命名
if wget -q -O "$OUTPUT_FILE" "$URL"; then
    # 提示下载完成
    echo "文件已成功下载并保存为 $OUTPUT_FILE"
else
    # 提示下载失败
    echo "文件下载失败，请检查 URL 或网络连接"
fi
