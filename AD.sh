!/bin/bash
# 定义输出文件路径（与脚本同目录）
OUTPUT_FILE="$(dirname "$0")/AD.txt"

# 下载文件并直接保存
curl -s -o "${OUTPUT_FILE}" https://raw.githubusercontent.com/qq5460168/666/master/dns.txt