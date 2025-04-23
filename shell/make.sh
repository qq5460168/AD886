#!/bin/bash

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义，便于修改
ad_file="AD.txt"
dnslist_file="dnslist.txt"
hosts_file="hosts.txt"
reserved_file="reservedHost.txt"
clash_file="Clash.yaml"
qxlist_file="qx.list"  # 新增 qx.list 文件路径

# 打印日志函数
log() {
  echo "[INFO] $1"
}

# 检查文件是否存在
check_file() {
  if [[ ! -f "$1" ]]; then
    log "文件 $1 不存在，退出脚本！"
    exit 1
  fi
}

# 统计 DNS 规则总数
log "统计 DNS 规则总数..."
dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | wc -l)

# 生成 Adblock Plus 格式规则文件
log "生成 Adblock Plus 格式规则文件 (${dnslist_file})..."
{
  echo "[Adblock Plus 2.0]"
  echo "! Title: 酷安反馈反馈"
  echo "! Homepage: https://github.com/qq5460168/AD886"
  echo "! by: 酷安@那个谁520"
  echo "! Total Count: $dnstotal"
  echo "! Update Time: $time"
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sort -u
} > "$dnslist_file"

# 提取保留区域
log "提取保留区域到临时文件 (${reserved_file})..."
sed -n '/^#Reserved area start/,/^#Reserved area end/p' "$hosts_file" > "$reserved_file"

# 生成 hosts 文件
log "生成 hosts 文件 (${hosts_file})..."
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

# 清理临时文件
log "清理临时文件 (${reserved_file})..."
rm -f "$reserved_file"

# 统计 hosts 规则总数并替换占位符
log "统计 hosts 规则总数..."
hosttotal=$(grep -E "^127\.0\.0\.1" "$hosts_file" | wc -l)
sed -i "s/HOSTCOUNT/$hosttotal/" "$hosts_file"

# 更新 AD.txt 文件中的时间和总数
log "更新 AD.txt 文件中的时间和总数..."
sed -i "s/! Update Time:.*/! Update Time: $time/g" "$ad_file"
total=$(grep -v "^!" "$ad_file" | wc -l)
sed -i "s/! Total Count:.*/! Total Count: $total/g" "$ad_file"

# 转换为 Clash 格式规则并生成 Clash.yaml
log "生成 Clash 格式规则文件 (${clash_file})..."
{
  echo "proxies:"
  echo "rules:"
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
} > "$clash_file"

# 从 AD.txt 提取规则并生成 qx.list 文件
log "生成 QX 规则文件 (${qxlist_file})..."
{
  echo "# Title: QX Rules"
  echo "# Homepage: https://github.com/qq5460168/AD886"
  echo "# by: 酷安@那个谁520"
  echo "# Update Time: $time"
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN,\1,reject/' | sort -u
} > "$qxlist_file"

# 脚本完成
log "规则已成功生成并保存为以下文件："
log "1. $dnslist_file"
log "2. $hosts_file"
log "3. $clash_file"
log "4. $qxlist_file"
exit 0
