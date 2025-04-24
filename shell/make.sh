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

list() {
  local header="[Adblock Plus 2.0]
! Title: $TITLE
! Homepage: $HOMEPAGE
! by: $AUTHOR
! Total Count: $(grep -E "^(\|\|)[^\/\^]+\^$" "${files[ad_file]}" | wc -l)
! Update Time: $time"
  generate_rule_file "${files[dnslist_file]}" "$header" "cat"
}

# 生成 hosts 文件
generate_hosts() {
  log "生成 hosts 文件 (${files[hosts_file]})..."
  sed -n '/^#Reserved area start/,/^#Reserved area end/p' "${files[hosts_file]}" > "${files[reserved_file]}" || true
  {
    echo "# Title: $TITLE"
    echo "# Homepage: $HOMEPAGE"
    echo "# by: $AUTHOR"
    echo "# Total Count: HOSTCOUNT"
    echo "# Update Time: $time"
    echo "127.0.0.1 localhost"
    echo "::1 localhost"
    grep -Ev "\!|\[|\*" "${files[dnslist_file]}" | sed -e 's/||/127.0.0.1 /g' -e "s/\^//g" | sort -u
    cat "${files[reserved_file]}"
  } > "${files[hosts_file]}"
  rm -f "${files[reserved_file]}"
  local hosttotal=$(grep -E "^127\.0\.0\.1" "${files[hosts_file]}" | wc -l)
  sed -i "s/HOSTCOUNT/$hosttotal/" "${files[hosts_file]}"
}

# 更新 AD.txt 文件
update_ad_file() {
  log "更新 AD.txt 文件中的时间和总数..."
  sed -i "s/! Update Time:.*/! Update Time: $time/g" "${files[ad_file]}"
  local total=$(grep -v "^!" "${files[ad_file]}" | wc -l)
  sed -i "s/! Total Count:.*/! Total Count: $total/g" "${files[ad_file]}"
}

# 生成 Clash 格式规则
generate_clash() {
  local header="payload:"
  generate_rule_file "${files[clash_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/  - \"\1\"/'"
}

# 生成 Quantumult X 规则
generate_qxlist() {
  local header="# Title: QX Rules
# Homepage: $HOMEPAGE
# by: $AUTHOR
# Update Time: $time"
  generate_rule_file "${files[qxlist_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN,\1,reject/'"
}

# 生成 SingBox SRS 格式规则
generate_srs() {
  local header="# Title: SingBox SRS Rules
# Homepage: $HOMEPAGE
# by: $AUTHOR
# Update Time: $time"
  generate_rule_file "${files[srs_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/full:DOMAIN-SUFFIX,\1,block/'"
}

# 生成 Invizible Pro 规则文件
generate_invizible() {
  local header="# Title: Invizible Pro Rules
# Homepage: $HOMEPAGE
# by: $AUTHOR
# Update Time: $time"
  generate_rule_file "${files[invizible_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/\1/'"
}

# 生成 Shadowrocket 规则文件
generate_shadowrocket() {
  local header="# Title: Shadowrocket Rules
# Homepage: $HOMEPAGE
# by: $AUTHOR
# Update Time: $time"
  generate_rule_file "${files[shadowrocket_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/DOMAIN-SUFFIX,\1,REJECT/'"
}

# 生成 AdClose 规则文件
generate_adclose() {
  local header="# Title: AdClose Rules
# Homepage: $HOMEPAGE
# by: $AUTHOR
# Update Time: $time"
  generate_rule_file "${files[adclose_file]}" "$header" "sed -E 's/^\|\|([^\/\^]+)\^$/domain, \1/'"
}

# 主流程
main() {
  log "开始生成规则文件..."
  generate_dnslist
  generate_hosts
  update_ad_file
  generate_clash
  generate_qxlist
  generate_srs
  generate_invizible
  generate_shadowrocket
  generate_adclose
  log "规则已成功生成并保存为以下文件："
  for key in "${!files[@]}"; do
    log "${files[$key]}"
  done
}

main