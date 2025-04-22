#!/bin/bash

# 定义输出文件路径（主目录）
OUTPUT_FILE="$HOME/AD.txt"

# 下载文件并直接保存到主目录
echo "正在下载文件到 $OUTPUT_FILE..."
curl -s -o "${OUTPUT_FILE}" "https://raw.githubusercontent.com/qq5460168/Who520/refs/heads/main/black.txt"

# 检查下载是否成功
if [[ $? -eq 0 ]]; then
  echo "文件下载成功，保存在: $OUTPUT_FILE"
else
  echo "文件下载失败，请检查网络或 URL 是否正确。"
  exit 1
fi