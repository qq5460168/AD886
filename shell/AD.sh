#!/bin/bash

URL="https://raw.githubusercontent.com/qq5460168/666/master/dns.txt"
OUTPUT_FILE="$HOME/AD.txt"

echo "开始替换 $OUTPUT_FILE 的内容..."

# 下载并替换内容
if wget -q -O "$OUTPUT_FILE" "$URL"; then
    echo "文件内容已成功替换为最新内容：$OUTPUT_FILE"
else
    echo "文件下载失败，请检查 URL 或网络连接"
    exit 1
fi

# 验证替换是否成功
if [ -f "$OUTPUT_FILE" ]; then
    echo "替换内容验证成功，文件已更新"
else
    echo "替换失败，文件未更新"
fi
