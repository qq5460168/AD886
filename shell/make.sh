#!/bin/bash

set -e  # 如果有任何命令出错，则立即退出脚本

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义
declare -A files=(
  ["ad_file"]="AD.txt"
  ["dnslist_file"]="dnslist.txt"
  ["hosts_file"]="hosts.txt"
  ["reserved_file"]="reservedHost.txt"
  ["clash_file"]="Clash.yaml"
  ["clash_meta_file"]="ClashMeta.yaml" # Clash Meta (Mihomo) 规则文件路径
  ["qxlist_file"]="qx.list"
  ["srs_file"]="singbox.srs"
  ["invizible_file"]="invizible.txt"
  ["shadowrocket_file"]="Shadowrocket.list"
  ["adclose_file"]="AdClose.txt"
)

# 通用标题信息
TITLE="酷安反馈反馈"
HOMEPAGE="https://github.com/qq5460168/AD886"
AUTHOR="酷安@那个谁520"

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
check_file "${files[ad_file]}"

# 通用规则生成函数
generate_rule_file() {
  local output_file="$1"
  local header="$2"
  local transform_command="$3"

  log "生成规则文件 (${output_file})..."
  {
    echo "$header"
    grep -E "^(\|\|)[^\/\^]+\^$" "${files[ad_file]}" | eval "$transform_command" | sort -u
  } > "$output_file"
}

# 生成 Clash Meta (Mihomo) 规则
generate_clash_meta() {
  local header="payload:"
  generate_rule_file "${files[clash_meta_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/  - \"\1\"/'"
}

# 生成其他规则文件函数省略...

# 主流程
main() {
  log "开始生成规则文件..."
  generate_clash_meta  # 新增 Clash Meta (Mihomo) 规则生成
  log "规则已成功生成并保存为以下文件："
  for key in "${!files[@]}"; do
    log "${files[$key]}"
  done
}

main