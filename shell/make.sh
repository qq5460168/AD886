#!/bin/bash

set -euo pipefail

# 获取北京时间（兼容 macOS/BSD 系统）
if date -v-1d &>/dev/null; then
  time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S'"+08:00")'（北京时间）'
else
  time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S %:z' --utc)'（北京时间）'
fi

# 配置文件参数
declare -A config=(
  ["ad_file"]="AD.txt"
  ["dnslist_file"]="dnslist.txt"
)

# 输出规则配置（格式名称、输出文件、标题、sed替换表达式）
declare -a rules_config=(
  "clash.yaml           Clash           '  - DOMAIN-SUFFIX,\1,REJECT'"
  "clash_meta.yaml     Clash Meta      '  - DOMAIN-SUFFIX,\1,REJECT'"
  "qx.list             Quantumult X    'HOST-SUFFIX,\1,REJECT'"
  "singbox.srs         SingBox SRS     'DOMAIN-SUFFIX,\1'"
  "invizible.txt       Invizible Pro   '\1'"
  "Shadowrocket.list   Shadowrocket    'DOMAIN-SUFFIX,\1,REJECT'"
  "AdClose.txt         AdClose         '\1'"
)

# 日志函数
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"
}

log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# 检查文件是否存在
check_file_exists() {
  local file_path="${config[$1]}"
  if [[ ! -f "$file_path" ]]; then
    log_error "关键文件 $1 (${file_path}) 不存在，退出脚本！"
    exit 1
  fi
}

# 生成规则文件
generate_rules() {
  local input_file="${config[ad_file]}"
  local filtered_rules
  filtered_rules=$(grep -E "^(\|\|)[^\/\^]+\^$" "$input_file") || {
    log_error "规则过滤失败，请检查输入文件格式"
    exit 1
  }

  for rule in "${rules_config[@]}"; do
    IFS=' ' read -ra cfg <<< "$rule"
    local output_file=${cfg[0]}
    local title=${cfg[1]}
    local sed_expr=${cfg[2]}

    log "正在生成: ${title} (${output_file})..."
    
    # 创建新文件
    : > "$output_file"

    # 生成文件头
    {
      echo "# Title: ${title} Rules"
      echo "# Homepage: https://github.com/qq5460168/AD886"
      echo "# Update Time: $time"
      [[ $output_file == *.yaml ]] && echo "payload:"
    } >> "$output_file"

    # 处理规则内容
    sed -E "s/^\|\|([^\/\^]+)\^$/${sed_expr}/" <<< "$filtered_rules" \
      | sort -u >> "$output_file"

    # 验证输出
    if [[ -s "$output_file" ]]; then
      log "生成成功: ${output_file}（大小: $(du -h "$output_file" | cut -f1)）"
    else
      log_error "生成失败: ${output_file} 内容为空！"
      rm -f "$output_file"
      return 1
    fi
  done
}

main() {
  log "===== 规则生成流程开始 ====="
  check_file_exists "ad_file"
  check_file_exists "dnslist_file"
  
  generate_rules

  log "===== 所有规则生成完成 ====="
}

main