#!/usr/bin/env python3
import os
import re
import requests
from datetime import datetime

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'

# 增强版正则表达式
COMMENT_REGEX = re.compile(r'^[!#]')
BLANK_REGEX = re.compile(r'^\s*$')
DOMAIN_REGEX = re.compile(
    r'^(@@)?(\|\|)([a-zA-Z0-9-*_.]+\.)+[a-zA-Z]{2,}(\^|\$|$)',  # 强制包含有效顶级域名
    re.IGNORECASE
)
ELEMENT_REGEX = re.compile(r'##[^{}]+$')  # 更严格的元素选择器验证
REGEX_RULE_REGEX = re.compile(r'^/.*/[igmsu]*$')  # 支持正则修饰符
MODIFIER_REGEX = re.compile(
    r'\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*$'  # 修饰符必须在末尾
)
SINGLE_PIPE_REGEX = re.compile(
    r'^\|https?://[^\s^]+'  # 单竖线规则必须包含协议头
)

def is_valid_rule(line):
    """严格验证规则有效性"""
    line = line.strip()
    if COMMENT_REGEX.match(line) or BLANK_REGEX.match(line):
        return False
    
    # 按优先级验证不同规则类型
    if line.startswith('@@') or line.startswith('||'):
        # 域名规则验证
        if not DOMAIN_REGEX.match(line):
            return False
        domain_part = line.split('||')[-1].split('^')[0].split('$')[0]
        
        # 通配符只能在开头或结尾
        if '*' in domain_part and not (domain_part.startswith('*') or domain_part.endswith('*')):
            return False
        
        # 必须包含有效顶级域名（如 .com）
        if '.' in domain_part and not re.search(r'\.[a-z]{2,}$', domain_part, re.I):
            return False
        return True
    
    elif line.startswith('##'):
        # 元素隐藏规则
        return ELEMENT_REGEX.match(line) is not None
    
    elif line.startswith('/') and line.endswith('/'):
        # 正则表达式规则
        return REGEX_RULE_REGEX.match(line) is not None
    
    elif line.startswith('|'):
        # 单竖线协议规则
        return SINGLE_PIPE_REGEX.match(line) is not None
    
    elif '$' in line:
        # 带修饰符的规则
        parts = line.split('$', 1)
        return MODIFIER_REGEX.match('$' + parts[1]) is not None
    
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
        for line in lines:
            if is_valid_rule(line):
                valid_rules.append(line)
            else:
                if line and not (COMMENT_REGEX.match(line) or BLANK_REGEX.match(line)):
                    invalid_rules.append(line)
        return valid_rules, invalid_rules
    except Exception as e:
        print(f"⚠️ 处理失败: {url} - {str(e)}")
        return [], []

# 以下 main() 函数保持不变...

if __name__ == '__main__':
    main()