#!/bin/bash

set -e  # 如果有任何命令出错，立即退出脚本

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义，便于修改
ad_file="AD.txt"
dnslist_file="dnslist.txt"
hosts_file="hosts.txt"
reserved_file="reservedHost.txt"
clash_file="Clash.yaml"
qxlist_file="qx.list"
srs_file="singbox.srs"
invizible_file="invizible.txt"
shadowrocket_file="Shadowrocket.list"
adclose_file="AdClose.txt"
clash_payload_file="ClashPayload.yaml"
surge_file="Surge.list"
loon_file="Loon.list"
adguard_file="AdGuardHome.txt"
smartdns_file="SmartDNS.conf"
privoxy_file="Privoxy.action"
v2ray_file="V2Ray.json"
dnsmasq_file="DNSMASQ.conf"

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

# 生成 Adblock Plus 格式规则
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

# 生成 hosts 文件
generate_hosts() {
  log "生成 hosts 文件 (${hosts_file})..."
  sed -n '/^#Reserved area start/,/^#Reserved area end/p' "$hosts_file" > "$reserved_file" || true
  {
    echo "# Title: 酷安反馈反馈"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Total Count: HOSTCOUNT"
    echo "# Update Time: $time"
    echo "127.0.0.1 localhost"
    echo "::1 localhost"
    grep -Ev "\!|\[|\*" "$dnslist_file" | sed -e 's/||/127.0.0.1 /g' -e "s/\^//g" | sort -u
    cat "$reserved_file"
  } > "$hosts_file"
  rm -f "$reserved_file"
  local hosttotal=$(grep -E "^127\.0\.0\.1" "$hosts_file" | wc -l)
  sed -i "s/HOSTCOUNT/$hosttotal/" "$hosts_file"
}

# 更新 AD 文件
update_ad_file() {
  log "更新 AD.txt 文件中的时间和总数..."
  sed -i "s/! Update Time:.*/! Update Time: $time/g" "$ad_file"
  local total=$(grep -v "^!" "$ad_file" | wc -l)
  sed -i "s/! Total Count:.*/! Total Count: $total/g" "$ad_file"
}

# 生成 Clash Payload 格式规则
generate_clash_payload() {
  log "生成 Clash Payload 格式规则文件 (${clash_payload_file})..."
  {
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - \'\1\'/' | sort -u
  } > "$clash_payload_file"
}

# 生成 Surge 规则
generate_surge() {
  log "生成 Surge 格式规则文件 (${surge_file})..."
  {
    echo "# Title: Surge Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$surge_file"
}

# 生成 Loon 规则
generate_loon() {
  log "生成 Loon 格式规则文件 (${loon_file})..."
  {
    echo "# Title: Loon Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$loon_file"
}

# 生成 AdGuard Home 规则
generate_adguard() {
  log "生成 AdGuard Home 格式规则文件 (${adguard_file})..."
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sort -u > "$adguard_file"
}

# 生成 SmartDNS 规则
generate_smartdns() {
  log "生成 SmartDNS 格式规则文件 (${smartdns_file})..."
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/address=\/\1\/#/' | sort -u > "$smartdns_file"
}

# 生成 Privoxy 规则
generate_privoxy() {
  log "生成 Privoxy 格式规则文件 (${privoxy_file})..."
  {
    echo "{+block}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/\1/' | sort -u
  } > "$privoxy_file"
}

# 生成 V2Ray 路由规则
generate_v2ray() {
  log "生成 V2Ray 路由规则文件 (${v2ray_file})..."
  {
    echo "{"
    echo "  \"domain\": ["
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/    \"domain:\1\",/' | sed '$ s/,$//' | sort -u
    echo "  ]"
    echo "}"
  } > "$v2ray_file"
}

# 生成 DNSMASQ 规则
generate_dnsmasq() {
  log "生成 DNSMASQ 格式规则文件 (${dnsmasq_file})..."
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/address=\/\1\/#/' | sort -u > "$dnsmasq_file"
}

# 主流程
main() {
  log "开始生成规则文件..."
  generate_dnslist
  generate_hosts
  update_ad_file
  generate_clash_payload
  generate_surge
  generate_loon
  generate_adguard
  generate_smartdns
  generate_privoxy
  generate_v2ray
  generate_dnsmasq
  log "规则已成功生成并保存为以下文件："
  log "1. $dnslist_file"
  log "2. $hosts_file"
  log "3. $clash_payload_file"
  log "4. $surge_file"
  log "5. $loon_file"
  log "6. $adguard_file"
  log "7. $smartdns_file"
  log "8. $privoxy_file"
  log "9. $v2ray_file"
  log "10. $dnsmasq_file"
}

main