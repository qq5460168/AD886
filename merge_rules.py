#!/usr/bin/env python3
import os
import re
import requests
from datetime import datetime

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'

# 正则表达式模式（新增注释匹配规则）
COMMENT_PATTERN = re.compile(r'\s*#.*$')  # 匹配行尾注释
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

def main():
    # 读取规则源列表，支持行尾注释（# 后为备注）
    with open(RULE_SOURCES_FILE) as f:
        sources = []
        for line in f:
            # 去除行尾注释和空白
            clean_line = COMMENT_PATTERN.sub('', line).strip()
            if clean_line:
                sources.append(clean_line)

    # 后续逻辑保持不变
    merged_rules = set()
    error_reports = {}

    for url in sources:
        print(f"📥 正在处理: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)
        
        if invalid_rules:
            error_reports[url] = invalid_rules
            print(f"  发现 {len(invalid_rules)} 条无效规则")

    # ... 其余代码不变

if __name__ == '__main__':
    main()