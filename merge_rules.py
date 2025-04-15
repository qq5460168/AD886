#!/usr/bin/env python3
import os
import re
import requests
from datetime import datetime
from urllib.parse import urlparse
from adblockparser import AdblockRule  # 需安装 pip install adblockparser

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
USER_RULES_FILE = 'user-rules.txt'  # 新增用户规则文件
OUTPUT_FILE = 'merged-filter.txt'
USER_AGENT = 'MergedFilterBot/1.0 (+https://github.com/yourusername/yourrepo)'

# 初始化专业规则验证器
validator = AdblockRule(
    supported_options=['domain', 'script', 'stylesheet', 'image']
)

def is_valid_rule(line: str) -> bool:
    """使用专业库严格验证规则有效性"""
    line = line.strip()
    
    # 跳过注释和空行
    if not line or line.startswith(('!', '#')):
        return False
    
    try:
        # 使用 Adblock 语法验证器
        return validator.is_filter(line) and all([
            '##' not in line or '?#?#' in line,  # 元素规则特殊检查
            'eval(' not in line.lower(),         # 排除危险规则
            'script:' not in line.lower()        # 排除可疑协议
        ])
    except:
        return False

def load_rules(url_or_path: str) -> tuple:
    """通用规则加载方法"""
    invalid_rules = []
    valid_rules = []
    
    try:
        # 处理本地文件
        if urlparse(url_or_path).scheme in ['file', '']:
            with open(url_or_path.split('file:')[-1], 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f]
        # 处理远程URL
        else:
            resp = requests.get(url_or_path, headers={'User-Agent': USER_AGENT}, timeout=15)
            resp.raise_for_status()
            lines = [line.strip() for line in resp.text.splitlines()]
        
        # 严格过滤
        for line in lines:
            if is_valid_rule(line):
                valid_rules.append(line)
            elif line.strip():
                invalid_rules.append(line)
                
        return valid_rules, invalid_rules
    
    except Exception as e:
        print(f"⚠️ 规则加载失败: {url_or_path} - {str(e)}")
        return [], []

def main():
    # 加载所有规则源（包括用户自定义规则）
    all_sources = []
    
    # 读取预设规则源
    with open(RULE_SOURCES_FILE) as f:
        all_sources.extend([line.strip() for line in f if line.strip()])
    
    # 添加用户规则文件
    if os.path.exists(USER_RULES_FILE):
        all_sources.append(f'file:{USER_RULES_FILE}')

    merged_rules = set()
    error_reports = {}

    # 处理所有规则源
    for source in all_sources:
        print(f"📥 正在处理: {source}")
        valid_rules, invalid_rules = load_rules(source)
        merged_rules.update(valid_rules)
        
        if invalid_rules:
            error_reports[source] = invalid_rules
            print(f"  已拦截 {len(invalid_rules)} 条无效规则")

    # 错误报告（显示前3条示例）
    if error_reports:
        print("\n⚠️ 无效规则拦截报告")
        for source, rules in error_reports.items():
            print(f"来源: {source}")
            for rule in rules[:3]:
                print(f"  - {rule}")
            if len(rules) > 3:
                print(f"  ... 共拦截 {len(rules)} 条无效规则")
            print("───")

    # 生成最终文件（按优先级排序）
    sorted_rules = sorted(
        merged_rules,
        key=lambda x: (
            not x.startswith('||'),  # 域名规则优先
            not x.startswith('##'),  # 元素规则其次
            x.lower()                # 字母排序
        )
    )

    # 写入文件头
    header = [
        '! Title: Strictly Validated Filter',
        '! Description: Merged with professional validation',
        f'! Updated: {datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")}',
        f'! Rules count: {len(sorted_rules)}',
        '! Homepage: https://github.com/yourusername/yourrepo\n'
    ]

    # 写入文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(header))
        f.write('\n'.join(sorted_rules))
    
    print(f"\n✅ 合并完成！有效规则数: {len(sorted_rules)}")
    print(f"❗ 共拦截 {sum(len(v) for v in error_reports.values())} 条无效规则")

if __name__ == '__main__':
    main()