#!/bin/bash

set -e  # 如果有任何命令出错，立即退出脚本

# 获取北京时间
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')'（北京时间）'

# 文件路径定义，便于修改
ad_file="AD.txt"
dnslist_file="dnslist.txt"
qxlist_file="qx.list"          # Quantumult X 规则文件路径
srs_file="singbox.srs"         # SingBox SRS 格式规则文件路径
invizible_file="invizible.txt" # Invizible Pro 规则文件路径
shadowrocket_file="Shadowrocket.list" # Shadowrocket 规则文件路径
adclose_file="AdClose.txt"     # AdClose 规则文件路径
clash_file="clash.yaml"        # Clash 规则文件路径
clash_meta_file="clash_meta.yaml" # Clash Meta (Mihomo) 规则文件路径

# 打印日志函数
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"
}

# 打印错误日志函数
log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# 检查文件是否存在
check_file_exists() {
  if [[ ! -f "$1" ]]; then
    log_error "文件 $1 不存在，退出脚本！"
    exit 1
  fi
}

# 备份文件
backup_file() {
  if [[ -f "$1" ]]; then
    cp "$1" "$1.bak"
    log "已备份文件: $1 -> $1.bak"
  fi
}

# 校验生成的文件
validate_file() {
  if [[ ! -f "$1" ]]; then
    log_error "文件 $1 生成失败！"
    exit 1
  fi
  log "文件 $1 生成成功，大小: $(du -h "$1" | cut -f1)"
}

# 生成 Clash 格式规则文件
generate_clash() {
  log "生成 Clash 格式规则文件 (${clash_file})..."
  backup_file "$clash_file"
  {
    echo "# Title: Clash Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# Update Time: $time"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$clash_file"
  validate_file "$clash_file"
}

# 生成 Clash Meta 格式规则文件
generate_clash_meta() {
  log "生成 Clash Meta 格式规则文件 (${clash_meta_file})..."
  backup_file "$clash_meta_file"
  {
    echo "# Title: Clash Meta Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# Update Time: $time"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/  - DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$clash_meta_file"
  validate_file "$clash_meta_file"
}

# 生成 Quantumult X 规则文件
generate_qxlist() {
  log "生成 Quantumult X 格式规则文件 (${qxlist_file})..."
  backup_file "$qxlist_file"
  {
    echo "# Title: Quantumult X Rules"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/HOST-SUFFIX,\1,REJECT/' | sort -u
  } > "$qxlist_file"
  validate_file "$qxlist_file"
}

# 生成 SingBox SRS 规则文件
generate_srs() {
  log "生成 SingBox SRS 格式规则文件 (${srs_file})..."
  backup_file "$srs_file"
  {
    echo "# Title: SingBox SRS Rules"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN-SUFFIX,\1/' | sort -u
  } > "$srs_file"
  validate_file "$srs_file"
}

# 生成 Invizible Pro 规则文件
generate_invizible() {
  log "生成 Invizible Pro 格式规则文件 (${invizible_file})..."
  backup_file "$invizible_file"
  {
    echo "# Title: Invizible Pro Rules"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/\1/' | sort -u
  } > "$invizible_file"
  validate_file "$invizible_file"
}

# 生成 Shadowrocket 规则文件
generate_shadowrocket() {
  log "生成 Shadowrocket 格式规则文件 (${shadowrocket_file})..."
  backup_file "$shadowrocket_file"
  {
    echo "# Title: Shadowrocket Rules"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN-SUFFIX,\1,REJECT/' | sort -u
  } > "$shadowrocket_file"
  validate_file "$shadowrocket_file"
}

# 生成 AdClose 规则文件
generate_adclose() {
  log "生成 AdClose 格式规则文件 (${adclose_file})..."
  backup_file "$adclose_file"
  {
    echo "# Title: AdClose Rules"
    echo "# Update Time: $time"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sed -E 's/^\|\|([^\/\^]+)\^$/\1/' | sort -u
  } > "$adclose_file"
  validate_file "$adclose_file"
}

# 主流程
main() {
  log "开始生成规则文件..."
  check_file_exists "$ad_file"

  generate_clash
  generate_clash_meta
  generate_qxlist
  generate_srs
  generate_invizible
  generate_shadowrocket
  generate_adclose

  log "规则生成完成。所有文件已成功生成。"
}

main