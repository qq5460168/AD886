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

# 检查文件是否存在
check_file() {
  if [[ ! -f "$1" ]]; then
    log "文件 $1 不存在，退出脚本！"
    exit 1
  fi
}

# 初始化检查
log "检查必要文件..."
check_file "$ad_file"

# 函数：生成 Clash 格式规则文件
generate_clash() {
  log "生成 Clash 格式规则文件 (${clash_file})..."
  {
    echo "# Title: Clash Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$clash_file"
}

# 函数：生成 Clash Meta (Mihomo) 格式规则文件
generate_clash_meta() {
  log "生成 Clash Meta (Mihomo) 格式规则文件 (${clash_meta_file})..."
  {
    echo "# Title: Clash Meta (Mihomo) Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$clash_meta_file"
}

# 其他规则生成函数（保持原样）

# 函数：统计 DNS 规则总数
generate_dnslist() {
  log "生成 Adblock Plus 格式规则文件 (${dnslist_file})..."
  local dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | wc -l)
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: 酷安反馈反馈"
    echo "! Homepage: https://github.com/qq5460168/AD886"
    echo "! by: 酷安@那个谁520"
    echo "! Total Count: $dnstotal"
    echo "! Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sort -u
  } > "$dnslist_file"
}

# 主流程
main() {
  log "开始生成规则文件..."
  generate_dnslist
  generate_clash
  generate_clash_meta # 新增 Clash Meta 规则生成调用
  # 可扩展：调用其他规则生成函数
  log "规则已成功生成并保存为以下文件："
  log "1. $dnslist_file"
  log "2. $clash_file"
  log "3. $clash_meta_file"
}

main
