#!/bin/bash

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义，便于修改
ad_file="AD.txt"
dnslist_file="dnslist.txt"
hosts_file="hosts.txt"
reserved_file="reservedHost.txt"
clash_file="Clash.yaml"

# 统计 DNS 规则总数
dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | wc -l)

# 生成 Adblock Plus 格式规则文件
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
sed -n '/^#Reserved area start/,/^#Reserved area end/p' hosts.txt > "$reserved_file"

# 生成 hosts 文件
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
rm -f "$reserved_file"

# 统计 hosts 规则总数并替换占位符
hosttotal=$(grep -E "^127\.0\.0\.1" "$hosts_file" | wc -l)
sed -i "s/HOSTCOUNT/$hosttotal/" "$hosts_file"

# 更新 AD.txt 文件中的时间和总数
sed -i "s/! Update Time:.*/! Update Time: $time/g" "$ad_file"
total=$(grep -v "^!" "$ad_file" | wc -l)
sed -i "s/! Total Count:.*/! Total Count: $total/g" "$ad_file"

# 转换为 Clash 格式规则并生成 Clash.yaml
{
  echo "proxies:"
  echo "rules:"
  grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
} > "$clash_file"

# 脚本完成
echo "规则已生成并保存为 $dnslist_file、$hosts_file 和 $clash_file"
exit 0
