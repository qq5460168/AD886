#!/bin/bash

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 统计 DNS 规则总数
dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" jiekouAD.txt | wc -l)

# 生成 Adblock Plus 格式规则文件
{
  echo "[Adblock Plus 2.0]"
  echo "! Title: 反馈群538268498"
  echo "! Homepage: https://github.com/790953214/qy-Ads-Rule"
  echo "! by: 酷安@大萌主"
  echo "! Total Count: $dnstotal"
  echo "! Update Time: $time"
  grep -E "^(\|\|)[^\/\^]+\^$" jiekouAD.txt | sort -u
} > dnslist.txt

# 提取保留区域
sed -n '/^#Reserved area start/,/^#Reserved area end/p' hosts.txt > reservedHost.txt

# 生成 hosts 文件
{
  echo "# Title: 反馈群538268498"
  echo "# Homepage: https://github.com/790953214/qy-Ads-Rule"
  echo "# by: 酷安@晴雅"
  echo "# Total Count: HOSTCOUNT"
  echo "# Update Time: $time"
  echo "127.0.0.1 localhost"
  echo "::1 localhost"
  grep -Ev "\!|\[|\*" dnslist.txt | sed -e 's/||/127.0.0.1 /g' -e "s/\^//g" | sort -u
  cat reservedHost.txt
} > hosts.txt
rm -f reservedHost.txt

# 统计 hosts 规则总数并替换占位符
hosttotal=$(grep -E "^0\.0\.0\.0" hosts.txt | wc -l)
sed -i "s/HOSTCOUNT/$hosttotal/" hosts.txt

# 更新 jiekouAD.txt
sed -i "s/! Update Time:.*/! Update Time: $time/g" jiekouAD.txt
total=$(grep -v "^!" jiekouAD.txt | wc -l)
sed -i "s/! Total Count:.*/! Total Count: $total/g" jiekouAD.txt

# 转换为 Clash 格式规则并生成 Clash.yaml
{
  echo "proxies:"
  echo "rules:"
  grep -E "^(\|\|)[^\/\^]+\^$" jiekouAD.txt | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
} > Clash.yaml

# 脚本完成
echo "规则已生成并保存为 dnslist.txt、hosts.txt 和 Clash.yaml"
exit 0
