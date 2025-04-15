#!/usr/bin/env python3
import os
import requests
from datetime import datetime
from urllib.parse import urlparse
from adblockparser import AdblockRule

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
USER_RULES_FILE = 'user-rules.txt'
OUTPUT_FILE = 'merged-filter.txt'
USER_AGENT = 'MergedFilterBot/1.0 (+https://github.com/yourusername/yourrepo)'

# 初始化专业规则验证器
validator = AdblockRule(
    supported_options=['domain', 'script', 'stylesheet', 'image']
)

def is_valid_rule(line: str) -> bool:
    """优化后的有效性验证"""
    line = line.strip()
    if not line or line.startswith(('!', '#')):
        return False
    
    try:
        return validator.is_filter(line) and all([
            'eval(' not in line.lower(),
            'script:' not in line.lower(),
            '$' not in line or 'redirect=' not in line  # 过滤重定向规则
        ])
    except:
        return False

def load_rules(source: str) -> tuple:
    """增强的规则加载方法"""
    try:
        # 处理本地文件
        if urlparse(source).scheme in ['file', '']:
            path = source.replace('file:', '').strip()
            with open(path, 'r', encoding='utf-8') as f:
                lines = [l.strip() for l in f]
        # 处理远程URL
        else:
            resp = requests.get(source, headers={'User-Agent': USER_AGENT}, timeout=15)
            resp.raise_for_status()
            lines = resp.text.splitlines()
        
        return (
            [line for line in lines if is_valid_rule(line)],
            [line for line in lines if line.strip() and not is_valid_rule(line)]
        )
    
    except Exception as e:
        print(f"⚠️ 加载失败: {source} - {type(e).__name__}: {str(e)}")
        return [], []

def main():
    # 加载所有规则源
    sources = []
    with open(RULE_SOURCES_FILE) as f:
        sources.extend([l.strip() for l in f if l.strip()])
    
    if os.path.exists(USER_RULES_FILE):
        sources.append(f'file:{USER_RULES_FILE}')

    merged_rules = set()
    errors = {}

    for src in sources:
        print(f"🔍 处理中: {src}")
        valid, invalid = load_rules(src)
        merged_rules.update(valid)
        if invalid:
            errors[src] = invalid
            print(f"  拦截无效规则: {len(invalid)} 条")

    # 生成最终文件
    sorted_rules = sorted(merged_rules, key=lambda x: (
        (0 if x.startswith('||') else 1),
        (0 if x.startswith('##') else 1),
        x.lower()
    ))

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join([
            '! Title: Verified Filter List',
            f'! Updated: {datetime.utcnow().isoformat() + "Z"}',
            f'! Rules: {len(sorted_rules)}',
            '! Homepage: https://example.com\n'
        ]))
        f.write('\n'.join(sorted_rules))
    
    print(f"\n✅ 成功生成 {len(sorted_rules)} 条规则")
    print(f"🛡️ 共拦截 {sum(len(v) for v in errors.values())} 条危险规则")

if __name__ == '__main__':
    main()