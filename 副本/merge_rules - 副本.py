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
    r'^(@@)?(\|\|?)?([a-zA-Z0-9-*_.]+)(\^|\$|/)?.*$'
)
ELEMENT_REGEX = re.compile(r'##.+')
REGEX_RULE_REGEX = re.compile(r'^/.*/$')
MODIFIER_REGEX = re.compile(
    r'\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*)$'
)

def download_rules(url):
    """返回 (有效规则列表, 无效规则列表)"""
    invalid_rules = []
    try:
        if url.startswith('file:'):
            file_path = url.split('file:')[1].strip()
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f]
        else:
            resp = requests.get(url, headers={'User-Agent': USER_AGENT}, timeout=15)
            resp.raise_for_status()
            lines = [line.strip() for line in resp.text.splitlines()]
        
        valid_rules = []
        for line in lines:
            if is_valid_rule(line):
                valid_rules.append(line)
            else:
                # 排除注释和空白行后记录无效规则
                if line and not (COMMENT_REGEX.match(line) or BLANK_REGEX.match(line)):
                    invalid_rules.append(line)
        return valid_rules, invalid_rules
    except Exception as e:
        print(f"⚠️ 处理失败: {url} - {str(e)}")
        return [], []

def is_valid_rule(line):
    """验证规则有效性"""
    if COMMENT_REGEX.match(line) or BLANK_REGEX.match(line):
        return False
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

    merged_rules = set()
    error_reports = {}

    for url in sources:
        print(f"📥 正在处理: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)
        
        if invalid_rules:
            error_reports[url] = invalid_rules
            print(f"  发现 {len(invalid_rules)} 条无效规则")

    # 输出错误报告
    if error_reports:
        print("\n⚠️ 错误规则汇总:")
        for source, rules in error_reports.items():
            print(f"来源: {source}")
            for rule in rules:
                print(f"  - {rule}")
            print("---")

    # 排序并生成最终文件
    sorted_rules = sorted(merged_rules, key=lambda x: (
        not x.startswith('||'),
        not x.startswith('##'),
        x
    ))

    # 生成文件头
    header = [
        '! Title: 那个谁520 个人合并规则',
        '! Description: Merged from multiple sources, filtered and deduplicated',
		f'! Rules: {len(sorted_rules)}',  # 必须保留这个统计行
        f'! Updated: {datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")}',
        f'! Rules count: {len(sorted_rules)}',
        '! Homepage: https://github.com/qq5460168/AD886',
        ''
    ]

    # 写入文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(header))
        f.write('\n')
        f.write('\n'.join(sorted_rules))
    
    print(f"\n✅ 处理完成！最终规则数: {len(sorted_rules)}")

if __name__ == '__main__':
    main()