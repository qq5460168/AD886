#!/usr/bin/env python3
import os
import re
import requests
import json
from datetime import datetime
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
STATS_FILE = 'rule_stats.json'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
TITLE = "Merged Rules"
VERSION = "1.0.0"
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
MAX_RULES = 500000

# 增强版正则表达式
REGEX_PATTERNS = {
    "comment": re.compile(r'^[!#]'),
    "blank": re.compile(r'^\s*$'),
    "domain": re.compile(
        r'^(@@)?(\|\|)(([a-zA-Z0-9-*_.]+\.)*[a-zA-Z]{2,})(\^|\$|/?)(.*)?$',
        re.IGNORECASE
    ),
    "element": re.compile(r'##[^{}]+$'),
    "regex_rule": re.compile(r'^/.*/[igmsu]*$'),
    "modifier": re.compile(r'\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*)$'),
    "single_pipe": re.compile(r'^\|https?://[^\s^]+')
}

def is_valid_rule(line):
    """严格验证规则有效性"""
    line = line.strip()
    if not line or REGEX_PATTERNS["comment"].match(line):
        return False
    
    # 分层验证逻辑
    if line.startswith('@@') or line.startswith('||'):
        if not REGEX_PATTERNS["domain"].match(line):
            return False
        domain_part = line.split('||')[-1].split('^')[0].split('$')[0]
        if '*' in domain_part and not (domain_part.startswith('*') or domain_part.endswith('*')):
            return False
        return True
    elif line.startswith('##'):
        return REGEX_PATTERNS["element"].search(line)
    elif line.startswith('/') and line.endswith('/'):
        return REGEX_PATTERNS["regex_rule"].match(line)
    elif line.startswith('|'):
        return REGEX_PATTERNS["single_pipe"].match(line)
    elif '$' in line:
        parts = line.split('$', 1)
        return REGEX_PATTERNS["modifier"].match('$' + parts[1])
    return False

def download_rules(url):
    """带重试机制和文件大小限制的下载函数"""
    session = requests.Session()
    retries = Retry(total=3, backoff_factor=1)
    session.mount('https://', HTTPAdapter(max_retries=retries))
    
    try:
        if url.startswith('file:'):
            file_path = url.split('file:')[1].strip()
            if not os.path.exists(file_path):
                raise FileNotFoundError(f"Local file not found: {file_path}")
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        else:
            resp = session.get(url, headers={'User-Agent': USER_AGENT}, timeout=15, stream=True)
            resp.raise_for_status()
            
            # 检查文件大小
            content_length = int(resp.headers.get('Content-Length', 0))
            if content_length > MAX_FILE_SIZE:
                raise ValueError(f"File size exceeds limit: {content_length/1024/1024:.2f}MB")
            
            content = resp.content.decode('utf-8')

        lines = [line.strip() for line in content.splitlines()]
        valid_rules = [line for line in lines if is_valid_rule(line)]
        invalid_rules = [line for line in lines if line and not is_valid_rule(line) 
                        and not REGEX_PATTERNS["comment"].match(line)]
        return valid_rules, invalid_rules

    except Exception as e:
        print(f"⚠️ Error processing {url}: {str(e)}")
        return [], []

# ...（保持原有write_stats和main函数，添加以下修改）

def main():
    merged_rules = set()
    error_reports = {}

    if not os.path.exists(RULE_SOURCES_FILE):
        raise FileNotFoundError(f"Rule sources file missing: {RULE_SOURCES_FILE}")

    with open(RULE_SOURCES_FILE, 'r', encoding='utf-8') as f:
        sources = [line.strip() for line in f if line.strip()]

    for url in sources:
        print(f"📥 Processing: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)
        
        if len(merged_rules) > MAX_RULES:
            raise ValueError(f"规则数量超过最大限制 {MAX_RULES}")
        
        if invalid_rules:
            error_reports[url] = invalid_rules

    # ...（保持原有排序和写入逻辑）