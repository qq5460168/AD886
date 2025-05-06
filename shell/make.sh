#!/bin/bash

set -e  # 如果有任何命令出错，立即退出脚本

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 新增：在线规则源配置
shadowrocket_url="https://johnshall.github.io/Shadowrocket-ADBlock-Rules-Forever/sr_cnip_ad.conf"
temp_conf="sr_cnip_ad.conf"

# 文件路径定义
ad_file="AD.txt"
dnslist_file="dnslist.txt"
hosts_file="hosts.txt"
qxlist_file="qx.list"
srs_file="singbox.srs"
invizible_file="invizible.txt"
shadowrocket_file="Shadowrocket.conf"  # 改为.conf扩展名
adclose_file="AdClose.txt"
clash_file="clash.yaml"
clash_meta_file="clash_meta.yaml"

# 打印日志函数
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"
}

# 新增：下载并预处理规则
download_rules() {
  log "正在下载最新Shadowrocket规则..."
  if ! curl -sSL "$shadowrocket_url" -o "$temp_conf"; then
    log "规则下载失败，请检查网络连接！"
    exit 1
  fi
  
  # 提取域名并转换为Adblock格式
  log "转换规则格式到Adblock Plus..."
  grep -E '^(DOMAIN-SUFFIX|DOMAIN),' "$temp_conf" | \
    sed -E 's/^DOMAIN(-SUFFIX)?,([^,]+),.*$/||\2^/' | \
    sort -u > "$ad_file"
}

# 检查文件是否存在
check_file() {
  if [[ ! -f "$1" ]]; then
    log "文件 $1 不存在，退出脚本！"
    exit 1
  fi
}

# 优化后的通用规则生成函数
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

# Shadowrocket专用处理函数
generate_shadowrocket() {
  log "生成 Shadowrocket 规则文件 (${shadowrocket_file})..."
  {
    echo "# Title: Shadowrocket Rules"
    echo "# Version: $(date +%Y%m%d)"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# Date: ${time}"
    echo "# Total count: $(grep -c '^DOMAIN' "$temp_conf")"
    echo ""
    
    # 保留原始规则格式
    grep -E '^(DOMAIN-SUFFIX|DOMAIN|IP-CIDR|PROCESS-NAME|USER-AGENT),' "$temp_conf"
    
    echo ""
    echo "# 广告规则结束"
  } > "$shadowrocket_file"
}

# 其他规则生成函数保持不变
# ... (保持原有generate_dnslist、generate_hosts等函数)

# 主流程
main() {
  log "开始处理规则..."
  download_rules
  check_file "$ad_file"
  
  log "开始生成规则文件..."
  generate_dnslist
  generate_hosts
  generate_qx
  generate_shadowrocket  # 特殊处理
  generate_adclose
  generate_singbox
  generate_invizible
  generate_clash
  generate_clash_meta

  log "规则已成功生成并保存为以下文件："
  log "1. ${shadowrocket_file} (Shadowrocket)"
  log "2. ${dnslist_file} (Adblock Plus)"
  log "3. ${hosts_file} (Hosts格式)"
  # ... 其他日志输出
}

main
