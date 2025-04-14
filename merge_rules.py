#!/usr/bin/env python3
import os
import re
import requests
from datetime import datetime

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'         # 规则源列表文件
OUTPUT_FILE = 'merged-filter.txt'        # 输出文件名
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'

# 正则表达式模式
COMMENT_REGEX = re.compile(r'^[!#]')     # 注释行
BLANK_REGEX = re.compile(r'^\s*$')       # 空白行
DOMAIN_REGEX = re.compile(
    r'^(\|\|?)?([a-zA-Z0-9-*_.]+)(\^|\$|/)?.*$'
)                                        # 基础域名规则
ELEMENT_REGEX = re.compile(r'##.+')      # 元素隐藏规则
REGEX_RULE_REGEX = re.compile(r'^/.*/$') # 正则表达式规则
MODIFIER_REGEX = re.compile(             # 修饰符检测
    r'\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*)$'
)

def download_rules(url):
    """下载规则文件并返回行列表"""
    try:
        resp = requests.get(url, headers={'User-Agent': USER_AGENT}, timeout=15)
        resp.raise_for_status()
        return [line.strip() for line in resp.text.splitlines()]
    except Exception as e:
        print(f"⚠️ 下载失败: {url} - {str(e)}")
        return []

def is_valid_rule(line):
    """验证规则有效性"""
    # 跳过注释和空行
    if COMMENT_REGEX.match(line) or BLANK_REGEX.match(line):
        return False
    
    # 检查各类型规则
    return any([
        DOMAIN_REGEX.match(line),
        ELEMENT_REGEX.search(line),
        REGEX_RULE_REGEX.match(line),
        MODIFIER_REGEX.search(line)
    ])

def main():
    # 读取规则源列表
    with open(RULE_SOURCES_FILE) as f:
        sources = [line.strip() for line in f if line.strip()]

    # 下载并合并所有规则
    merged_rules = set()
    for url in sources:
        print(f"📥 正在处理: {url}")
        rules = download_rules(url)
        valid_count = 0
        
        for line in rules:
            if is_valid_rule(line):
                merged_rules.add(line)
                valid_count += 1
        
        print(f"  已添加 {valid_count} 条有效规则")

    # 排序并生成最终文件
    sorted_rules = sorted(merged_rules, key=lambda x: (
        not x.startswith('||'),  # 域名规则在前
        not x.startswith('##'),  # 元素隐藏规则在后
        x
    ))

    # 生成文件头
    header = [
        '! Title: Merged AdGuard Filter',
        '! Description: Merged from multiple sources, filtered and deduplicated',
        f'! Updated: {datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")}',
        f'! Rules count: {len(sorted_rules)}',
        '! Homepage: https://github.com/yourusername/yourrepo',
        ''
    ]

    # 写入文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(header))
        f.write('\n'.join(sorted_rules))
    
    print(f"✅ 处理完成！最终规则数: {len(sorted_rules)}")

if __name__ == '__main__':
    main()