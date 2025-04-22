#!/bin/bash
set -euo pipefail

# 获取北京时间
readonly UPDATE_TIME=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径：保存到用户主目录，避免权限问题
readonly AD_FILE="$HOME/AD.txt"
readonly HOSTS_FILE="$HOME/hosts.txt"
readonly DNSLIST_FILE="$HOME/dnslist.txt"
readonly CLASH_FILE="$HOME/Clash.yaml"

# 创建临时目录
readonly TEMP_DIR=$(mktemp -d)

# 清理函数：确保退出时清理临时文件
clean_up() {
  rm -rf "$TEMP_DIR"
  echo "Cleaned up temporary files."
}
trap clean_up EXIT

# 文件检查函数：确保必要的文件存在
check_files() {
  local required_files=("$AD_FILE" "$HOSTS_FILE")
  for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "Error: Required file '$file' not found. Please ensure the file exists." >&2
      exit 1
    fi
  done
}

# 生成 DNS 规则文件
generate_dns_rules() {
  echo "Generating DNS rules..."
  local dnstotal
  dnstotal=$(grep -Ec "^(\|\|)[^\/\^]+\^$" "$AD_FILE")

  # 如果没有匹配的规则，发出警告
  if [[ $dnstotal -eq 0 ]]; then
    echo "Warning: No valid DNS rules found in $AD_FILE."
  fi

  # 创建 dnslist.txt 文件
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

  # 提取保留区域的 Hosts 信息（如果存在）
  if grep -q "^#Reserved area start" "$HOSTS_FILE"; then
    sed -n '/^#Reserved area start/,/^#Reserved area end/p' "$HOSTS_FILE" > "$TEMP_DIR/reservedHost.txt"
  else
    echo "Warning: Reserved area not found in $HOSTS_FILE. Skipping reserved hosts."
    > "$TEMP_DIR/reservedHost.txt" # 创建空文件
  fi

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

  # 替换占位符 HOSTCOUNT
  local hosttotal
  hosttotal=$(grep -Ec "^0\.0\.0\.0" "$HOSTS_FILE")
  sed -i "s/HOSTCOUNT/$hosttotal/" "$HOSTS_FILE"
}

# 更新 AD.txt 的元数据
update_ad_metadata() {
  echo "Updating AD.txt metadata..."
  local total_rules
  total_rules=$(grep -c "^" "$AD_FILE")

  # 检查是否存在元数据字段
  if ! grep -q "! Update Time:" "$AD_FILE"; then
    echo "Warning: '! Update Time:' not found in $AD_FILE. Adding it."
    echo "! Update Time: $UPDATE_TIME" >> "$AD_FILE"
  fi
  if ! grep -q "! Total Count:" "$AD_FILE"; then
    echo "Warning: '! Total Count:' not found in $AD_FILE. Adding it."
    echo "! Total Count: $total_rules" >> "$AD_FILE"
  fi

  # 更新元数据
  sed -i.bak \
    -e "s/! Update Time:.*/! Update Time: $UPDATE_TIME/" \
    -e "s/! Total Count:.*/! Total Count: $total_rules/" \
    "$AD_FILE"
  rm -f "$AD_FILE.bak"
}

# 生成 Clash 规则
generate_clash_rules() {
  echo "Generating Clash rules..."

  # 检查是否有有效规则
  if ! grep -qE "^(\|\|)[^\/\^]+\^$" "$AD_FILE"; then
    echo "Warning: No valid Clash rules found in $AD_FILE."
  fi

  # 创建 Clash.yaml 文件
  {
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
  } > "$CLASH_FILE"
}

# 主函数
main() {
  # 检查文件
  check_files

  # 按顺序执行生成规则的步骤
  generate_dns_rules
  generate_hosts
  update_ad_metadata
  generate_clash_rules

  # 打印完成信息
  echo "规则已生成并保存为以下文件："
  echo "- DNS规则: $DNSLIST_FILE"
  echo "- Hosts文件: $HOSTS_FILE"
  echo "- Clash规则: $CLASH_FILE"
}

# 调用主函数
main
exit 0