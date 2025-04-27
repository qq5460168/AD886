#!/bin/bash
set -euo pipefail  # 严格错误处理

TARGET_DIR="${HOME}/ad_rules"
mkdir -p "${TARGET_DIR}"

# 下载并验证文件
if ! wget -q --spider https://raw.githubusercontent.com/qq5460168/666/master/dns.txt; then
  echo "Error: Source file not reachable!"
  exit 1
fi

wget -O "${TARGET_DIR}/AD.txt" https://raw.githubusercontent.com/qq5460168/666/master/dns.txt

# 验证文件内容
if [[ ! -s "${TARGET_DIR}/AD.txt" ]]; then
  echo "Error: Downloaded file is empty!"
  exit 1
fi

echo "文件已成功下载至 ${TARGET_DIR}/AD.txt"