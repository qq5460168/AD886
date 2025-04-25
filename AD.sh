#!/bin/bash

# 定义下载的目标文件路径
OUTPUT_FILE="$HOME/AD.txt"

# 使用 curl 下载文件到目标路径
curl -s -o "${OUTPUT_FILE}" https://raw.githubusercontent.com/qq5460168/666/master/dns.txt

# 检查文件是否下载成功
if [ $? -eq 0 ]; then
    echo "文件已成功下载并保存为 ${OUTPUT_FILE}"
else
    echo "文件下载失败，请检查网络连接或目标 URL 是否正确"
    exit 1
fi