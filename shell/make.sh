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

# 各规则生成函数
generate_dnslist() {
  log "生成 Adblock Plus 格式规则文件 (${dnslist_file})..."
  local dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | wc -l)
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: 酷安反馈反馈"
    echo "! Homepage: https://github.com/qq5460168/AD886"
    echo "! by: 酷安@那个谁520"
    echo "! Total Count: ${dnstotal}"
    echo "! Update Time: ${time}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sort -u
  } > "$dnslist_file"
}

generate_hosts() {
  generate_rules "Hosts" "0.0.0.0 \1" "$hosts_file"
}

generate_qx() {
  generate_rules "Quantumult X" "HOST-SUFFIX,\1,REJECT" "$qxlist_file"
}

generate_shadowrocket() {
  generate_rules "Shadowrocket" "DOMAIN-SUFFIX,\1,REJECT" "$shadowrocket_file"
}

generate_adclose() {
  log "生成 AdClose 专用规则文件 (${adclose_file})..."
  {
    echo "# AdClose 专用广告规则"
    echo "# 格式：domain, <域名>"
    echo "# 生成时间: ${time}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
    sed -E 's/^\|\|([^\/\^]+)\^$/domain, \1/' | \
    sort -u
  } > "$adclose_file"
}

generate_singbox() {
  generate_rules "SingBox SRS" "DOMAIN-SUFFIX,\1,REJECT" "$srs_file"
}

generate_invizible() {
  generate_rules "Invizible Pro" "\1" "$invizible_file"
}

generate_clash() {
  generate_rules "Clash" "  - DOMAIN-SUFFIX,\1,REJECT" "$clash_file"
}

generate_clash_meta() {
  log "生成 Clash Meta 专用规则文件 (${clash_meta_file})..."
  {
    echo "# Clash Meta 专用规则 (简化域名列表格式)"
    echo "# 生成时间: ${time}"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
    sed -E "s/^\|\|([^\/\^]+)\^$/  - '\1'/" | \
    sort -u
  } > "$clash_meta_file"
}

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
  log "1. ${dnslist_file} (Adblock Plus)"
  log "2. ${hosts_file} (Hosts 格式)"
  log "3. ${qxlist_file} (Quantumult X)"
  log "4. ${shadowrocket_file} (Shadowrocket)"
  log "5. ${adclose_file} (AdClose)"
  log "6. ${srs_file} (SingBox SRS)"
  log "7. ${invizible_file} (Invizible Pro)"
  log "8. ${clash_file} (Clash)"
  log "9. ${clash_meta_file} (Clash Meta)"
}

main