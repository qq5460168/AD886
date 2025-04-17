#!/usr/bin/env python3
import os
import re
import requests
from datetime import datetime

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'

# 正则表达式模块化
REGEX_PATTERNS = {
    "comment": re.compile(r'^[!#]'),
    "blank": re.compile(r'^\s*$'),
    "domain": re.compile(r'^(@@)?(\|\|)?([a-zA-Z0-9-*_.]+)(\^|\$|/)?'),
    "element": re.compile(r'##.+'),
    "regex_rule": re.compile(r'^/.*/$'),
    "modifier": re.compile(r'\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*)$')
}

def is_valid_rule(line):
    """验证规则有效性"""
    if REGEX_PATTERNS["comment"].match(line) or REGEX_PATTERNS["blank"].match(line):
        return False
    return any([
        REGEX_PATTERNS["domain"].match(line),
        REGEX_PATTERNS["element"].search(line),
        REGEX_PATTERNS["regex_rule"].match(line),
        REGEX_PATTERNS["modifier"].search(line)
    ])

def download_rules(url):
    """下载规则并验证"""
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
                if line and not (REGEX_PATTERNS["comment"].match(line) or REGEX_PATTERNS["blank"].match(line)):
                    invalid_rules.append(line)
        return valid_rules, invalid_rules
    except Exception as e:
        print(f"⚠️ 处理失败: {url} - {str(e)}")
        return [], []

def main():
    print("📂 开始处理规则文件")
    merged_rules = set()
    error_reports = {}

    with open(RULE_SOURCES_FILE, 'r', encoding='utf-8') as f:
        sources = [line.strip() for line in f if line.strip()]

    for url in sources:
        print(f"📥 正在处理: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)

        if invalid_rules:
            error_reports[url] = invalid_rules
            print(f"  ⚠️ 发现 {len(invalid_rules)} 条无效规则")

    if error_reports:
        print("\n⚠️ 错误规则汇总:")
        for source, rules in error_reports.items():
            print(f"来源: {source}")
            for rule in rules:
                print(f"  - {rule}")

    # 排序规则
    sorted_rules = sorted(merged_rules, key=lambda x: (
        not x.startswith('||'),
        not x.startswith('##'),
        x
    ))

    # 写入到输出文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sorted_rules))
    print(f"✅ 规则合并完成，输出到 {OUTPUT_FILE}")

if __name__ == "__main__":
    main()