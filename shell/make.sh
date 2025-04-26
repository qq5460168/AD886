#!/bin/bash
set -euo pipefail

# 时区校准函数（兼容全平台）
get_beijing_time() {
    if command -v tzutil &>/dev/null; then
        # Windows系统
        date +'%Y-%m-%d %H:%M:%S +0800'
    else
        # Unix/Linux/macOS系统
        TZ=Asia/Shanghai date +'%Y-%m-%d %H:%M:%S %z' | 
        awk '{sub(/:30$/, "00", $2); print $1" "substr($2,1,5)"00"}'
    fi
}

# 配置文件参数
declare -A config=(
    ["ad_file"]="AD.txt"
    ["dnslist_file"]="dnslist.txt"
)

# 输出规则配置（格式名称 标题 sed表达式 验证正则）
declare -a rules_config=(
    "clash.yaml        Clash           '  - DOMAIN-SUFFIX,\1,REJECT'        '^  - DOMAIN-SUFFIX,[a-zA-Z0-9-]+\\..+,REJECT$'"
    "clash_meta.yaml   Clash Meta      '  - DOMAIN-SUFFIX,\1,REJECT'        '^  - DOMAIN-SUFFIX,[a-zA-Z0-9-]+\\..+,REJECT$'"
    "qx.list          Quantumult X    'HOST-SUFFIX,\1,REJECT'              '^HOST-SUFFIX,[a-zA-Z0-9-]+\\..+,REJECT$'"
    "singbox.srs      SingBox SRS     'DOMAIN-SUFFIX,\1'                   '^DOMAIN-SUFFIX,[a-zA-Z0-9-]+\\..+$'"
    "invizible.txt    Invizible Pro   '\1'                                 '^[a-zA-Z0-9-]+\\..+$'"
    "Shadowrocket.list Shadowrocket   'DOMAIN-SUFFIX,\1,REJECT'            '^DOMAIN-SUFFIX,[a-zA-Z0-9-]+\\..+,REJECT$'"
    "AdClose.txt      AdClose         '\1'                                 '^[a-zA-Z0-9-]+\\..+$'"
    "hosts.txt        Hosts           '127.0.0.1 \1'                       '^127\\.0\\.0\\.1 [a-zA-Z0-9-]+\\..+$'"
)

# 日志函数
log() {
    echo "$(get_beijing_time) [INFO] $1"
}

log_error() {
    echo "$(get_beijing_time) [ERROR] $1" >&2
}

# 严格域名验证函数
validate_domain() {
    local domain="$1"
    [[ "$domain" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$ ]] || return 1
    [[ "$domain" != *"*"* ]] || return 1
    return 0
}

# 生成规则文件
generate_rules() {
    local input_file="${config[ad_file]}"
    local valid_count=0 invalid_count=0
    
    log "开始处理输入文件: ${input_file}"
    
    # 创建临时处理文件
    local temp_file=$(mktemp)
    
    # 预处理输入文件
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^! ]] && continue
        
        # 提取Adblock格式域名
        if [[ "$line" =~ ^\|\|([^\^/]+)\^$ ]]; then
            local domain="${BASH_REMATCH[1]}"
            if validate_domain "$domain"; then
                echo "||${domain}^" >> "$temp_file"
                ((valid_count++))
            else
                ((invalid_count++))
                log_error "无效域名格式: $domain"
            fi
        else
            ((invalid_count++))
            log_error "无法解析的行: ${line:0:40}..."
        fi
    done < "$input_file"
    
    # 检查有效规则数量
    if ((valid_count == 0)); then
        log_error "未找到有效规则，请检查输入文件格式"
        rm "$temp_file"
        exit 1
    fi
    
    log "规则预处理完成 (有效: $valid_count / 无效: $invalid_count)"
    
    # 生成各格式规则文件
    for rule in "${rules_config[@]}"; do
        IFS=' ' read -ra cfg <<< "$rule"
        local output_file=${cfg[0]}
        local title=${cfg[1]}
        local sed_expr=${cfg[2]}
        local validation_regex=${cfg[3]}
        
        log "正在生成: ${title} (${output_file})..."
        
        # 生成文件头
        {
            echo "# Title: ${title} Rules"
            echo "# Project: https://github.com/qq5460168/AD886"
            echo "# Updated: $(get_beijing_time)"
            [[ $output_file == *.yaml ]] && echo "payload:"
        } > "$output_file"
        
        # 处理规则内容
        sed -E "s/^\|\|([^\^]+)\^$/${sed_expr}/" "$temp_file" |
        sort -u |
        awk '!seen[$0]++' >> "$output_file"
        
        # 格式验证
        local invalid_lines=$(grep -vE "$validation_regex" "$output_file" | wc -l)
        if ((invalid_lines > 0)); then
            log_error "发现 ${invalid_lines} 行无效格式，建议人工检查"
        fi
        
        # 结果验证
        if [[ -s "$output_file" ]]; then
            log "生成成功: ${output_file} (条目: $(wc -l < "$output_file"))"
        else
            log_error "生成失败: ${output_file} 内容为空！"
            rm -f "$output_file"
        fi
    done
    
    # 清理临时文件
    rm "$temp_file"
}

# 主流程
main() {
    log "===== 规则生成启动 ====="
    log "系统原始时间: $(date)"
    log "校准后时间: $(get_beijing_time)"
    
    # 输入文件检查
    for key in "ad_file" "dnslist_file"; do
        if [[ ! -f "${config[$key]}" ]]; then
            log_error "关键文件缺失: ${config[$key]}"
            exit 1
        fi
    done
    
    generate_rules
    
    log "===== 生成流程完成 ====="
    log "输出文件列表:"
    ls -lh $(printf "%s " "${rules_config[@]%% *}") | awk '{print $5,$9}'
}

main