#!/bin/bash
set -euo pipefail

# 全局常量
readonly UPDATE_TIME=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'
readonly AD_FILE="AD.txt"
readonly HOSTS_FILE="hosts.txt"
readonly TEMP_DIR=$(mktemp -d)

# 清理函数
cleanup() {
  rm -rf "$TEMP_DIR"
  echo "Cleaned up temporary files."
}
trap cleanup EXIT

# 检查文件存在性
check_files() {
  local required_files=("$AD_FILE" "$HOSTS_FILE")
  for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "Error: Required file '$file' not found." >&2
      exit 1
    fi
  done
}

# 生成DNS规则
generate_dns_rules() {
  echo "Generating DNS rules..."
  local dnstotal=$(grep -Ec "^(\|\|)[^\/\^]+\^$" "$AD_FILE")
  
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: 反馈群538268498"
    echo "! Homepage: https://github.com/790953214/qy-Ads-Rule"
    echo "! by: 酷安@大萌主"
    echo "! Total Count: $dnstotal"
    echo "! Update Time: $UPDATE_TIME"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | sort -u
  } > dnslist.txt
}

# 生成Hosts文件
generate_hosts() {
  echo "Generating hosts file..."
  # 提取保留区域
  sed -n '/^#Reserved area start/,/^#Reserved area end/p' "$HOSTS_FILE" > "$TEMP_DIR/reservedHost.txt"

  # 处理DNS规则为Hosts格式
  grep -Ev "\!|\[|\*" dnslist.txt | \
    sed -e 's/||/127.0.0.1 /g' -e "s/\^//g" | \
    sort -u > "$TEMP_DIR/processed_hosts.txt"

  # 合并内容
  {
    echo "# Title: 反馈群538268498"
    echo "# Homepage: https://github.com/790953214/qy-Ads-Rule"
    echo "# by: 酷安@晴雅"
    echo "# Total Count: HOSTCOUNT"
    echo "# Update Time: $UPDATE_TIME"
    echo "127.0.0.1 localhost"
    echo "::1 localhost"
    cat "$TEMP_DIR/processed_hosts.txt"
    cat "$TEMP_DIR/reservedHost.txt"
  } > "$HOSTS_FILE"

  # 更新Hosts计数
  local hosttotal=$(grep -Ec "^127\.0\.0\.1" "$HOSTS_FILE")
  sed -i "s/HOSTCOUNT/$hosttotal/" "$HOSTS_FILE"
}

# 更新AD.txt元数据
update_ad_metadata() {
  echo "Updating AD.txt metadata..."
  local total_rules=$(grep -cv "^!" "$AD_FILE")
  sed -i.bak "
    /! Update Time:/c\\! Update Time: $UPDATE_TIME
    /! Total Count:/c\\! Total Count: $total_rules
  " "$AD_FILE"
  rm -f "$AD_FILE.bak"
}

# 生成Clash规则
generate_clash_rules() {
  echo "Generating Clash rules..."
  {
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | \
      sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1/g' | \
      sort -u
  } > Clash.yaml
}

main() {
  check_files
  generate_dns_rules
  generate_hosts
  update_ad_metadata
  generate_clash_rules
  echo "规则已生成并保存为 dnslist.txt、hosts.txt 和 Clash.yaml"
}

main
exit 0