#!/usr/bin/env python3
import os
import re
import requests
from datetime import datetime

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'

# 正则表达式模式
COMMENT_REGEX = re.compile(r'^[!#]')
BLANK_REGEX = re.compile(r'^\s*$')
DOMAIN_REGEX = re.compile(
    r'^(@@)?(\|\|)(([a-zA-Z0-9-*_]+\.)+[a-zA-Z]{2,}|\*)(\^|\$|$)',  # 严格域名验证
    re.IGNORECASE
)
SINGLE_PIPE_REGEX = re.compile(
    r'^\|https?://[^\s^]+'  # 必须包含协议头
)
ELEMENT_REGEX = re.compile(r'##[^{}]+$')  # 简单元素选择器验证
MODIFIER_REGEX = re.compile(
    r'^.*?\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*)$'  # 修饰符验证
)
REGEX_RULE_REGEX = re.compile(r'^/.*/[igmsu]*$')  # 正则表达式规则

def is_valid_rule(line):
    """严格验证规则有效性"""
    if COMMENT_REGEX.match(line) or BLANK_REGEX.match(line):
        return False
    
    line = line.strip()
    
    # 类型 1：域名规则 (||example.com^)
    if line.startswith('@@') or line.startswith('||'):
        if not DOMAIN_REGEX.match(line):
            return False
        domain_part = line.split('||')[-1].split('^')[0].split('$')[0]
        
        # 检查通配符位置
        if '*' in domain_part:
            if not (domain_part.startswith('*') or domain_part.endswith('*')):
                return False
            if domain_part.count('*') > 1:
                return False
        
        # 检查顶级域有效性
        if '.' in domain_part and not re.search(r'\.[a-z]{2,}$', domain_part, re.I):
            return False
        
        return True
    
    # 类型 2：单竖线协议规则 (|http://...)
    if line.startswith('|'):
        return SINGLE_PIPE_REGEX.match(line) is not None
    
    # 类型 3：元素隐藏规则 (##selector)
    if line.startswith('##'):
        return ELEMENT_REGEX.match(line) is not None
    
    # 类型 4：正则表达式规则 (/ads/)
    if line.startswith('/') and line.endswith('/'):
        return REGEX_RULE_REGEX.match(line) is not None
    
    # 类型 5：带修饰符的规则 ($script,important)
    if '$' in line:
        parts = line.rsplit('$', 1)
        if len(parts) != 2:
            return False
        return MODIFIER_REGEX.match(line) is not None
    
    return False

def download_rules(url):
    """返回 (有效规则列表, 无效规则列表)"""
    invalid_rules = []
    try:
        if url.startswith('file:'):
            file_path = url.split('file:')[1].strip()
            print(f"📂 加载本地文件: {os.path.abspath(file_path)}")
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f]
        else:
            resp = requests.get(url, headers={'User-Agent': USER_AGENT}, timeout=15)
            resp.raise_for_status()
            lines = [line.strip() for line in resp.text.splitlines()]
        
        valid_rules = []
        for idx, line in enumerate(lines, 1):
            if is_valid_rule(line):
                valid_rules.append(line)
                # print(f"✅ 有效规则: {line[:60]}")
            else:
                if line:
                    invalid_rules.append(line)
                    # print(f"❌ 无效规则: {line[:60]}")
        return valid_rules, invalid_rules
    except Exception as e:
        print(f"⚠️ 处理失败: {url} - {str(e)}")
        return [], []

def main():
    with open(RULE_SOURCES_FILE) as f:
        sources = [line.strip() for line in f if line.strip()]

    merged_rules = set()
    error_reports = {}

    for url in sources:
        print(f"📥 正在处理: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)
        
        if invalid_rules:
            error_reports[url] = invalid_rules
            print(f"  发现 {len(invalid_rules)} 条无效规则")

    # 错误报告
    if error_reports:
        print("\n⚠️ 无效规则汇总:")
        for source, rules in error_reports.items():
            print(f"来源: {source}")
            for rule in rules:
                print(f"  - {rule}")
            print("---")

    # 排序规则
    sorted_rules = sorted(merged_rules, key=lambda x: (
        not x.startswith('||'),
        not x.startswith('##'),
        x
    ))

    # 生成文件头
    header = [
        '! Title: 合并过滤规则',
        '! Description: 严格验证后的合并规则',
        f'! Updated: {datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")}',
        f'! Rules count: {len(sorted_rules)}',
        '! Homepage: https://github.com/example/merge-rules',
        ''
    ]

    # 写入文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(header))
        f.write('\n')
        f.write('\n'.join(sorted_rules))
    
    print(f"\n✅ 处理完成！有效规则数: {len(sorted_rules)}")
    print(f"输出文件: {os.path.abspath(OUTPUT_FILE)}")

if __name__ == '__main__':
    main()