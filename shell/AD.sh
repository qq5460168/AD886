#!/bin/bash
# 定义输出文件路径（主目录）
OUTPUT_FILE="$HOME/AD.txt"

# 下载文件并直接保存
curl -s -o "${OUTPUT_FILE}" https://raw.githubusercontent.com/qq5460168/Who520/refs/heads/main/black.txt
