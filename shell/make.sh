#!/bin/bash

set -e  # 如果有任何命令出错，立即退出脚本

# 获取北京时间
time=$(TZ="$3"
  log "生成 ${comment} 规则文件 (${file})..."
  {
    echo "# Title: ${comment} Rules"
    echo "# Homepage: https://github.com/qq5460168/AD886"
    echo "# by: 酷安@那个谁520"
    echo "# Update Time: ${time}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
    sed -E "s/^\|\|([^\/\^]+)\^$/${suffix}/" | \
    sort -u
  } > "$file"
}

# 各规则生成函数
generate_dnslist() {
  log "生成 Adblock Plus 格式规则文件 (${dnslist_file})..."
  local dnstotal=$(grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | wc -l)
  {
    echo "[Adblock Plus 2.0]"
    echo "! Title: 酷安反馈反馈"
    echo "! Homepage: https://github.com/qq5460168/AD886"
    echo "! by: 酷安@那个谁520"
    echo "! Total Count: ${dnstotal}"
    echo "! Update Time: ${time}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | sort -u
  } > "$dnslist_file"
}

generate_hosts() {
  generate_rules "Hosts" "0.0.0.0 \1" "$hosts_file"
}

generate_qx() {
  generate_rules "Quantumult X" "HOST-SUFFIX,\1,REJECT" "$qxlist_file"
}

generate_shadowrocket() {
  generate_rules "Shadowrocket" "DOMAIN-SUFFIX,\1,REJECT" "$shadowrocket_file"
}

generate_adclose() {
  log "生成 AdClose 专用规则文件 (${adclose_file})..."
  {
    echo "# AdClose 专用广告规则"
    echo "# 格式：domain, <域名>"
    echo "# 生成时间: ${time}"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
    sed -E 's/^\|\|([^\/\^]+)\^$/domain, \1/' | \
    sort -u
  } > "$adclose_file"
}

generate_singbox() {
  generate_rules "SingBox SRS" "DOMAIN-SUFFIX,\1,REJECT" "$srs_file"
}

# 新增：生成 Singbox JSON 规则
generate_singbox_json() {
  log "生成 Singbox JSON 规则文件 (${singbox_json_file})..."
  {
    echo "{"
    echo "  \"name\": \"Singbox Ads Rule\","
    echo "  \"type\": \"domain\","
    echo "  \"payload\": ["
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
      sed -E "s/^\|\|([^\/\^]+)\^$/    \"\1\",/" | \
      sort -u | sed '$ s/,$//'
    echo "  ]"
    echo "}"
  } > "$singbox_json_file"

  if [ $? -eq 0 ]; then
    log "成功生成 Singbox JSON 规则文件 (${singbox_json_file})！"
  else
    log "生成 Singbox JSON 文件失败！"
    exit 1
  fi
}

generate_invizible() {
  generate_rules "Invizible Pro" "\1" "$invizible_file"
}

generate_clash() {
  generate_rules "Clash" "  - DOMAIN-SUFFIX,\1,REJECT" "$clash_file"
}

generate_clash_meta() {
  log "生成 Clash Meta 专用规则文件 (${clash_meta_file})..."
  {
    echo "# Clash Meta 专用规则 (简化域名列表格式)"
    echo "# 生成时间: ${time}"
    echo "payload:"
    grep -E "^(\|\|)[^\/\^]+\^$" "$ad_file" | \
    sed -E "s/^\|\|([^\/\^]+)\^$/  - '\1'/" | \
    sort -u
  } > "$clash_meta_file"
}

# 主流程
main() {
  log "开始生成规则文件..."
  generate_dnslist
  generate_hosts
  generate_qx
  generate_shadowrocket
  generate_adclose
  generate_singbox
  generate_singbox_json  # 调用新增的 JSON 规则生成函数
  generate_invizible
  generate_clash
  generate_clash_meta
  
  log "规则已成功生成并保存为以下文件："
  log "1. ${dnslist_file} (Adblock Plus)"
  log "2. ${hosts_file} (Hosts 格式)"
  log "3. ${qxlist_file} (Quantumult X)"
  log "4. ${shadowrocket_file} (Shadowrocket)"
  log "5izible Pro)"
  log "9. ${clash_file} (Clash)"
  log "10. ${clash_meta_file} (Clash Meta)"
}

main