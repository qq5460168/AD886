#!/bin/bash
set -euo pipefail
trap 'echo "Error occurred at line $LINENO. Exiting script."; exit 1' ERR

# 配置路径：默认保存到用户主目录
OUTPUT_DIR="${OUTPUT_DIR:-$HOME}"
readonly AD_FILE="$OUTPUT_DIR/AD.txt"
readonly HOSTS_FILE="$OUTPUT_DIR/hosts.txt"
readonly DNSLIST_FILE="$OUTPUT_DIR/dnslist.txt"
readonly CLASH_FILE="$OUTPUT_DIR/Clash.yaml"

# 临时目录
readonly TEMP_DIR=$(mktemp -d)
clean_up() {
  if [[ -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
    echo "Cleaned up temporary files."
  fi
}
trap clean_up EXIT

# 检查文件
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
  if [[ $dnstotal -eq 0 ]]; then
    echo "Warning: No valid DNS rules found in $AD_FILE."
  fi
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: 示例规则"
    echo "! Homepage: https://github.com/qq5460168/AD886"
    echo "! Total Count: $dnstotal"
    echo "! Update Time: $(date)"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | sort -u
  } > "$DNSLIST_FILE"
}

# 生成 Hosts 文件
generate_hosts() {
  echo "Generating hosts file..."
  if grep -q "^#Reserved area start" "$HOSTS_FILE"; then
    sed -n '/^#Reserved area start/,/^#Reserved area end/p' "$HOSTS_FILE" > "$TEMP_DIR/reservedHost.txt"
  else
    echo "Warning: Reserved area not found in $HOSTS_FILE."
    > "$TEMP_DIR/reservedHost.txt"
  fi
  {
    echo "127.0.0.1 localhost"
    echo "::1 localhost"
    grep -Ev "\!|\[|\*" "$DNSLIST_FILE" | sed -e 's/||/0.0.0.0 /g' -e "s/\^//g" | sort -u
    cat "$TEMP_DIR/reservedHost.txt"
  } > "$HOSTS_FILE"
}

# 生成 Clash 配置
generate_clash_rules() {
  echo "Generating Clash rules..."
  {
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$AD_FILE" | sed -E 's/^\|\|([^\/\^]+)\^$/- DOMAIN-SUFFIX,\1/g' | sort -u
  } > "$CLASH_FILE"
}

# 主函数
main() {
  echo "Step 1: Checking required files..."
  check_files

  echo "Step 2: Generating DNS rules..."
  generate_dns_rules

  echo "Step 3: Generating hosts file..."
  generate_hosts

  echo "Step 4: Generating Clash rules..."
  generate_clash_rules

  echo "All tasks completed successfully!"
}

main