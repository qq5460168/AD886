#!/bin/bash

# 设置脚本出错时立即退出
set -e

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
  local level="$1"
  local message="$2"
  echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] $message"
}

# 文件检查函数
check_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    log "ERROR" "文件 $file 不存在！"
    exit 1
  fi
}

# 规则文件生成函数
generate_rule_file() {
  local output_file="$1"
  local header="$2"
  local transform_command="$3"

  log "INFO" "开始生成规则文件: ${output_file}..."
  {
    echo "$header"
    grep -E "^(\|\|)[^\/\^]+\^$" "${files[ad_file]}" | eval "$transform_command" | sort -u
  } > "$output_file"
  log "INFO" "规则文件 ${output_file} 生成完成。"
}

# 生成 Clash Meta (Mihomo) 规则
generate_clash_meta() {
  local header="payload:"
  local transform_command="sed -E 's/^\|\|([^\/\^]+)\^$/  - \"\1\"/'"
  generate_rule_file "${files[clash_meta_file]}" "$header" "$transform_command"
}

# 其他规则文件的生成函数可以类似添加...

# 主流程函数
main() {
  log "INFO" "脚本开始运行..."

  # 检查必要文件
  log "INFO" "检查必要文件是否存在..."
  check_file "${files[ad_file]}"

  # 生成规则文件
  log "INFO" "开始生成规则文件..."
  generate_clash_meta

  # 打印生成的文件列表
  log "INFO" "规则已生成并保存为以下文件："
  for key in "${!files[@]}"; do
    log "INFO" "${files[$key]}"
  done

  log "INFO" "脚本运行结束。"
}

# 执行主流程
main
