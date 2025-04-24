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
qxlist_file="qx.list"          # Quantumult X 规则文件路径
srs_file="singbox.srs"         # SingBox SRS 格式规则文件路径
invizible_file="invizible.txt" # Invizible Pro 规则文件路径
shadowrocket_file="Shadowrocket.list" # Shadowrocket 规则文件路径
adclose_file="AdClose.txt"     # AdClose 规则文件路径

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

# 统计 DNS 规则总数
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

# 更新 AD.txt 文件
update_ad_file() {
  log "更新 AD.txt 文件中的时间和总数..."
  sed -i "s/! Update Time:.*/! Update Time: $time/g" "$ad_file"
  local total=$(grep -v "^!" "$ad_file" | wc -l)
  sed -i "s/! Total Count:.*/! Total Count: $total/g" "$ad_file"
}

# 生成 Clash 格式规则
generate_clash() {
  log "生成 Clash 格式规则文件 (${clash_file})..."
  {
    echo "proxies:"
    echo "rules:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
  } > "$clash_file"
}

# 生成 Quantumult X 规则
generate_qxlist() {
  log "生成 QX 规则文件 (${qxlist_file})..."
  {
    echo "# Title: QX Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN,\1,reject/' | sort -u
  } > "$qxlist_file"
}

# 生成 SingBox SRS 格式规则
generate_srs() {
  log "生成 SingBox SRS 格式规则文件 (${srs_file})..."
  {
    echo "# Title: SingBox SRS Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/full:DOMAIN-SUFFIX,\1,block/' | sort -u
  } > "$srs_file"
}

# 生成 Invizible Pro 规则文件
generate_invizible() {
  log "生成 Invizible Pro 格式规则文件 (${invizible_file})..."
  {
    echo "# Title: Invizible Pro Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/\1/' | sort -u
  } > "$invizible_file"
}

# 生成 Shadowrocket 规则文件
generate_shadowrocket() {
  log "生成 Shadowrocket 格式规则文件 (${shadowrocket_file})..."
  {
    echo "# Title: Shadowrocket Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$shadowrocket_file"
}

# 生成 AdClose 规则文件
generate_adclose() {
  log "生成 AdClose 格式规则文件 (${adclose_file})..."
  {
    echo "# Title: AdClose Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/domain, \1/' | sort -u
  } > "$adclose_file"
}

# 主流程
main() {
  log "开始生成规则文件..."
  generate_dnslist
  generate_hosts
  update_ad_file
  generate_clash
  generate_qxlist
  generate_srs
  generate_invizible
  generate_shadowrocket
  generate_adclose
  log "规则已成功生成并保存为以下文件："
  log "1. $dnslist_file"
  log "2. $hosts_file"
  log "3. $clash_file"
  log "4. $qxlist_file"
  log "5. $srs_file"
  log "6. $invizible_file"
  log "7. $shadowrocket_file"
  log "8. $adclose_file"
}

main