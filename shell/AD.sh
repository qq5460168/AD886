#!/bin/bash
set -euo pipefail

# 配置项
readonly URL="https://raw.githubusercontent.com/qq5460168/666/master/dns.txt"
readonly OUTPUT_FILE="$HOME/AD.txt"
readonly BACKUP_DIR="$HOME/backups"
readonly TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RESET='\033[0m'

# 日志函数
log() {
    local level=$1
    local message=$2
    local color
    
    case "$level" in
        "SUCCESS") color=${COLOR_GREEN} ;;
        "ERROR") color=${COLOR_RED} ;;
        "WARN") color=${COLOR_YELLOW} ;;
        *) color=${COLOR_RESET} ;;
    esac
    
    printf "[%(%Y-%m-%d %H:%M:%S)T] [${color}%s${COLOR_RESET}] %s\n" -1 "$level" "$message"
}

# 依赖检查
check_dependencies() {
    local missing=()
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        missing+=("wget 或 curl")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "ERROR" "缺少必需依赖: ${missing[*]}"
        log "WARN" "请使用以下命令安装:"
        [[ -z "$(command -v apt-get)" ]] || echo "  sudo apt-get install wget"
        [[ -z "$(command -v yum)" ]] || echo "  sudo yum install wget"
        exit 1
    fi
}

# 创建备份
create_backup() {
    mkdir -p "$BACKUP_DIR"
    local backup_file="${BACKUP_DIR}/AD_${TIMESTAMP}.txt"
    
    if cp "$OUTPUT_FILE" "$backup_file"; then
        log "SUCCESS" "创建备份成功: ${backup_file}"
    else
        log "ERROR" "文件备份失败 (code:$?)"
        exit 1
    fi
}

# 下载文件
download_file() {
    log "INFO" "开始下载更新文件..."
    
    if command -v wget &> /dev/null; then
        if ! wget --tries=3 --timeout=15 -qO "$OUTPUT_FILE" "$URL"; then
            log "ERROR" "wget 下载失败 (code:$?)"
            return 1
        fi
    else
        if ! curl --retry 2 --connect-timeout 10 -sSo "$OUTPUT_FILE" "$URL"; then
            log "ERROR" "curl 下载失败 (code:$?)"
            return 1
        fi
    fi
    
    log "SUCCESS" "文件下载完成"
}

# 验证文件
validate_file() {
    if [ ! -s "$OUTPUT_FILE" ]; then
        log "ERROR" "文件为空或不存在"
        return 1
    fi
    
    if ! file "$OUTPUT_FILE" | grep -q "text"; then
        log "ERROR" "文件格式异常 (非文本文件)"
        return 1
    fi
    
    if grep -qP '[^\x00-\x7F]' "$OUTPUT_FILE"; then
        log "WARN" "检测到非ASCII字符，可能存在异常内容"
    fi
    
    log "SUCCESS" "文件验证通过 (大小: $(du -h "$OUTPUT_FILE" | cut -f1))"
}

# 主流程
main() {
    log "INFO" "=== 开始执行更新流程 ==="
    
    check_dependencies
    
    if [ -f "$OUTPUT_FILE" ]; then
        create_backup
    else
        log "WARN" "目标文件不存在，将创建新文件"
    fi
    
    if download_file; then
        validate_file
    else
        log "ERROR" "更新流程失败，保留备份文件: ${BACKUP_DIR}/AD_${TIMESTAMP}.txt"
        exit 1
    fi
    
    log "INFO" "=== 更新流程成功完成 ==="
}

main