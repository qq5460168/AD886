#!/bin/bash

# 定义下载 URL 和输出文件路径
URL="https://raw.githubusercontent.com/qq5460168/666/master/dns.txt"
OUTPUT_FILE="$HOME/AD.txt"
BACKUP_FILE="${OUTPUT_FILE}.bak"

# 函数：打印日志信息
log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message"
}

# 准备开始
log "INFO" "开始执行脚本..."

# 检查依赖工具 wget 或 curl 是否安装
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q -O \"$OUTPUT_FILE\" \"$URL\""
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -s -o \"$OUTPUT_FILE\" \"$URL\""
else
    log "ERROR" "未找到 wget 或 curl 工具，请安装后重试。"
    exit 1
fi

# 备份旧文件
if [ -f "$OUTPUT_FILE" ]; then
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        log "INFO" "已备份旧文件为 $BACKUP_FILE"
    else
        log "ERROR" "备份旧文件失败，退出脚本。"
        exit 1
    fi
fi

# 下载文件并替换内容
log "INFO" "正在下载文件并更新到 $OUTPUT_FILE..."
eval "$DOWNLOAD_CMD"
if [ $? -eq 0 ]; then
    log "INFO" "文件下载成功，已更新内容到 $OUTPUT_FILE"
else
    log "ERROR" "文件下载失败，请检查网络连接或 URL 是否正确。"
    exit 1
fi

# 验证文件是否存在且非空
if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
    log "INFO" "文件验证成功，已更新且非空。"
else
    log "ERROR" "文件验证失败，可能文件为空或不存在。"
    exit 1
fi

log "INFO" "脚本执行完成。"