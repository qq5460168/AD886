#!/bin/bash

# 定义下载的目标文件路径
OUTPUT_FILE="$HOME/AD.txt"

# 检查 curl 是否可用
if ! command -v curl &> /dev/null; then
    echo "错误: curl 未安装。请先安装 curl 后再运行脚本。"
    exit 1
fi

# 下载文件到目标路径
curl -s -o "${OUTPUT_FILE}" https://raw.githubusercontent.com/qq5460168/666/master/dns.txt

# 检查下载是否成功
if [ $? -eq 0 ] && [ -s "${OUTPUT_FILE}" ]; then
    echo "文件已成功下载并保存为 ${OUTPUT_FILE}"
else
    echo "错误: 文件下载失败，请检查网络连接或 URL 是否正确。"
    exit 1
fi