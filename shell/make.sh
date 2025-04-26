#!/bin/bash

set -e  # 如果有任何命令出错，立即退出脚本

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义，便于修改
ad_file="AD.txt"
dnslist_file="dnslist.txt"
hosts_file="hosts.txt"
reserved_file="reservedHost.txt"
qxlist_file="qx.list"          # Quantumult X 规则文件路径
srs_file="singbox.srs"         # SingBox SRS 格式规则文件路径
invizible_file="invizible.txt" # Invizible Pro 规则文件路径
shadowrocket_file="Shadowrocket.list" # Shadowrocket 规则文件路径
adclose_file="AdClose.txt"     # AdClose 规则文件路径
clash_file="clash.yaml"        # Clash 规则文件路径
clash_meta_file="clash_meta.yaml" # Clash Meta (Mihomo) 规则文件路径

# 打印日志函数
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"
}

# 打印错误日志函数
log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# 文件检查函数
check_file_exists() {
  if [[ ! -f "$1" ]]; then
    log_error "文件 $1 不存在，退出脚本！"
    exit 1
  fi
}

# 文件备份函数
backup_file() {
  if [[ -f "$1" ]]; then
    cp "$1" "$1.bak"
    log "已备份文件: $1 -> $1.bak"
  fi
}

# 调试规则数量
debug_rules() {
  local rules=$(grep -E "^(\|\|)[^\/\^]+\^$" "$1")
  log "匹配的规则总数: $(echo "$rules" | wc -l)"
}

# 函数：生成 Clash 格式规则文件
generate_clash() {
  log "生成 Clash 格式规则文件 (${clash_file})..."
  backup_file "$clash_file"
  {
    echo "# Title: Clash Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$clash_file"
  log "规则文件 ${clash_file} 生成完成。"
}

# 函数：生成 Clash Meta 格式规则文件
generate_clash_meta() {
  log "生成 Clash Meta 格式规则文件 (${clash_meta_file})..."
  backup_file "$clash_meta_file"
  {
    echo "# Title: Clash Meta (Mihomo) Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$clash_meta_file"
  log "规则文件 ${clash_meta_file} 生成完成。"
}

# 函数：生成 Adblock Plus 格式规则文件
generate_dnslist() {
  log "生成 Adblock Plus 格式规则文件 (${dnslist_file})..."
  backup_file "$dnslist_file"
  local dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | wc -l)
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: Adblock DNS List"
    echo "! Homepage: https://github.com/qq5460168/AD886"
    echo "! by: 酷安@那个谁520"
    echo "! Total Count: $dnstotal"
    echo "! Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sort -u
  } > "$dnslist_file"
  log "规则文件 ${dnslist_file} 生成完成，总计规则数：$dnstotal。"
}

# 函数：验证规则文件是否生成成功
validate_file() {
  if [[ ! -f "$1" ]]; then
    log_error "文件 $1 生成失败！"
    exit 1
  fi
  log "文件 $1 生成成功，大小: $(du -h "$1" | cut -f1)"
}

# 主流程
main() {
  log "开始生成规则文件..."

  # 检查规则文件是否存在
  check_file_exists "$ad_file"

  # 调试规则数量
  debug_rules "$ad_file"

  # 生成规则文件
  generate_dnslist
  validate_file "$dnslist_file"

  generate_clash
  validate_file "$clash_file"

  generate_clash_meta
  validate_file "$clash_meta_file"

  log "规则生成流程完成。"
  log "生成的文件列表："
  log "1. $dnslist_file"
  log "2. $clash_file"
  log "3. $clash_meta_file"
}

main