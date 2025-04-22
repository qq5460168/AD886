#!/bin/bash
set -euo pipefail

# 获取北京时间
readonly UPDATE_TIME=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'
readonly AD_FILE="/AD.txt"             # 修改为主目录路径
readonly HOSTS_FILE="/hosts.txt"       # 修改为主目录路径
readonly DNSLIST_FILE="/dnslist.txt"   # 修改为主目录路径
readonly CLASH_FILE="/Clash.yaml"      # 修改为主目录路径
readonly TEMP_DIR=$(mktemp -d)

# 清理函数
clean_up() {
  rm -rf "$TEMP_DIR"
  echo "Cleaned up temporary files."
}
trap clean_up EXIT

# 文件检查函数
check_files() {
  local required_files=("$AD_FILE" "$HOSTS_FILE")
  for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "Error: Required file '$file' not found." >&2
      exit 1
    fi
  done
}

# 生成 DNS 规则
generate_dns_rules() {
  echo "Generating DNS rules..."
  local dnstotal=$(grep -Ec "^(\|\|)[^\/\^]+\^$" "$AD_FILE")
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: 示例规则"
    echo "! Homepage: https://github.com/qq5460168/AD886"
    echo "! Total Count: $dnstotal"
    echo "! Update Time: $UPDATE_TIME"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | sort -u
  } > "$DNSLIST_FILE"
}

# 生成 Hosts 文件
generate_hosts() {
  echo "Generating hosts file..."
  # 提取保留区域 Hosts 信息
  sed -n '/^#Reserved area start/,/^#Reserved area end/p' "$HOSTS_FILE" > "$TEMP_DIR/reservedHost.txt"

  # 生成完整的 Hosts 文件
  {
    echo "# Title: 示例规则"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# Total Count: HOSTCOUNT"
    echo "# Update Time: $UPDATE_TIME"
    echo "127.0.0.1 localhost"
    echo "::1 localhost"
    grep -Ev "\!|\[|\*" "$DNSLIST_FILE" | sed -e 's/||/0.0.0.0 /g' -e "s/\^//g" | sort -u
    cat "$TEMP_DIR/reservedHost.txt"
  } > "$HOSTS_FILE"

  # 替换总数占位符
  local hosttotal=$(grep -Ec "^0\.0\.0\.0" "$HOSTS_FILE")
  sed -i "s/HOSTCOUNT/$hosttotal/" "$HOSTS_FILE"
}

# 更新规则文件元数据
update_ad_metadata() {
  echo "Updating AD.txt metadata..."
  local total_rules=$(grep -c "^" "$AD_FILE")
  sed -i.bak \
    -e "s/! Update Time:.*/! Update Time: $UPDATE_TIME/" \
    -e "s/! Total Count:.*/! Total Count: $total_rules/" \
    "$AD_FILE"
  rm -f "$AD_FILE.bak"
}

# 生成 Clash 规则
generate_clash_rules() {
  echo "Generating Clash rules..."
  {
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
  } > "$CLASH_FILE"
}

# 主函数
main() {
  check_files
  generate_dns_rules
  generate_hosts
  update_ad_metadata
  generate_clash_rules
  echo "规则已生成并保存为 $DNSLIST_FILE、$HOSTS_FILE 和 $CLASH_FILE"
}

main
exit 0