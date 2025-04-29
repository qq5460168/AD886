#!/bin/bash

set -e  # 如果有任何命令出错，立即退出脚本

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义
ad_file="AD.txt"
dnslist_file="dnslist.txt"
hosts_file="hosts.txt"
qxlist_file="qx.list"
srs_file="singbox.srs"
invizible_file="invizible.txt"
shadowrocket_file="Shadowrocket.list"
adclose_file="AdClose.txt"
clash_file="clash.yaml"
clash_meta_file="clash_meta.yaml"

# AD.txt 文件下载地址
ad_url="https://raw.githubusercontent.com/qq5460168/666/master/dns.txt"  # ← 替换为实际URL

# 打印日志函数
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"
}

# 检查命令是否存在
check_command() {
  if ! command -v "$1" &> /dev/null; then
    log "错误：未找到 $1 命令，请先安装"
    exit 1
  fi
}

# 下载 AD.txt 文件
download_ad_file() {
  log "开始下载 AD.txt 文件..."
  if curl -sL "$ad_url" -o "$ad_file"; then
    log "AD.txt 下载成功"
  else
    log "AD.txt 下载失败，请检查 URL 或网络连接"
    exit 1
  fi
}

# 初始化检查
log "检查必要组件..."
check_command "curl"
download_ad_file

# 函数：生成通用规则模板
generate_rules() {
  local comment="$1"
  local suffix="$2"
  local file="$3"
  log "生成 ${comment} 规则文件 (${file})..."
  {
    echo "# Title: ${comment} Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: ${time}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
      sed -E "s/^\|\|([^\/\^]+)\^$/${suffix}/" | \
      sort -u
  } > "$file"
}

# 各规则生成函数保持不变...
# [以下保持原有 generate_dnslist、generate_hosts 等函数不变]

# 主流程
main() {
  log "开始生成规则文件..."
  generate_dnslist
  generate_hosts
  generate_qx
  generate_shadowrocket
  generate_adclose
  generate_singbox
  generate_invizible
  generate_clash
  generate_clash_meta
  
  log "规则已成功生成并保存为以下文件："
  log "1. ${dnslist_file}"
  log "2. ${hosts_file}"
  log "3. ${qxlist_file}"
  log "4. ${shadowrocket_file}"
  log "5. ${adclose_file}"
  log "6. ${srs_file}"
  log "7. ${invizible_file}"
  log "8. ${clash_file}"
  log "9. ${clash_meta_file}"
}

main
