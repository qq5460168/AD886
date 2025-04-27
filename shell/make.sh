#!/bin/bash
set -euo pipefail

# 获取兼容的时间格式
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S %:z' || date -u +'%Y-%m-%d %H:%M:%S %:z')"（北京时间）"

declare -A config=(
  ["ad_file"]="AD.txt"
  ["dnslist_file"]="dnslist.txt"
)

declare -a rules_config=(
  "clash.yaml         Clash           '  - DOMAIN-SUFFIX,\1,REJECT'"
  "clash_meta.yaml   Clash Meta      '  - DOMAIN-SUFFIX,\1,REJECT'"
  "qx.list           Quantumult X    'HOST-SUFFIX,\1,REJECT'"
  "singbox.srs       SingBox SRS     'DOMAIN-SUFFIX,\1'"
  "invizible.txt     Invizible Pro   '\1'"
  "Shadowrocket.list Shadowrocket    'DOMAIN-SUFFIX,\1,REJECT'"
  "AdClose.txt       AdClose         '\1'"
)

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"
}

check_file_exists() {
  local file_path="${config[$1]}"
  [[ -f "$file_path" ]] || { 
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] 关键文件 $1 (${file_path}) 不存在" >&2
    exit 1
  }
}

generate_rules() {
  local input_file="${config[ad_file]}"
  local filtered_rules=$(grep -E "^(\|\|)[^\/\^]+\^$" "$input_file")

  for rule in "${rules_config[@]}"; do
    IFS=' ' read -ra cfg <<< "$rule"
    output_file=${cfg[0]}
    title=${cfg[1]}
    sed_expr=${cfg[2]}

    log "生成: ${title} (${output_file})..."
    
    # 生成文件头
    {
      printf "# Title: %s Rules\n" "$title"
      echo "# Homepage: https://github.com/qq5460168/AD886"
      echo "# Update Time: $time"
      [[ $output_file == *.yaml ]] && echo "payload:"
    } > "$output_file"

    # 处理规则内容
    sed -E "s/^\|\|([^\/\^]+)\^$/${sed_expr}/" <<< "$filtered_rules" \
      | sort -u >> "$output_file"

    [[ -s "$output_file" ]] || {
      log_error "${output_file} 内容为空"
      exit 1
    }
  done
}

main() {
  log "===== 规则生成开始 ====="
  check_file_exists "ad_file"
  check_file_exists "dnslist_file"
  generate_rules
  log "===== 规则生成完成 ====="
}

main