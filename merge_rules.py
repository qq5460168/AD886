#!/usr/bin/env python3
import os
import re
import json
import hashlib
from datetime import datetime
from typing import Tuple, List, Dict, Set
from concurrent.futures import ThreadPoolExecutor, as_completed
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from adblockparser import AdblockRule

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
CACHE_DIR = "rule_cache"
ALLOWED_LOCAL_PATHS = ["./rules/"]
USER_AGENT = 'MergedFilterBot/1.0 (+https://github.com/yourusername/yourrepo)'
VERSION_FILE = "version.txt"

# 请求会话配置
session = requests.Session()
retries = Retry(
    total=3,
    backoff_factor=0.3,
    status_forcelist=[429, 500, 502, 503, 504],
    allowed_methods=["GET"]
)
session.mount('https://', HTTPAdapter(max_retries=retries))

def get_cache_key(url: str) -> str:
    """生成基于URL的缓存文件名"""
    return hashlib.md5(url.encode()).hexdigest() + ".json"

def normalize_rule(rule: str) -> str:
    """统一规则格式以提升去重精度"""
    rule = rule.strip()
    
    # 标准化域名规则
    if rule.startswith("||") and not rule.endswith("^"):
        if '/' in rule or '*' in rule:
            return rule
        return f"{rule}^"
    
    # 标准化元素选择器
    if rule.startswith("##") and not rule.startswith("##^"):
        return rule.replace("##", "##^")
    
    return rule

def is_valid_rule(rule: str) -> bool:
    """使用专业库验证规则有效性"""
    try:
        ab_rule = AdblockRule(rule)
        return ab_rule.is_filter and not any(
            kw in rule.lower() 
            for kw in ['eval(', 'script', 'javascript:']
        )
    except:
        return False

def download_rules(url: str) -> Tuple[List[str], List[str]]:
    """下载并验证规则，支持缓存和本地文件"""
    invalid_rules = []
    cache_file = os.path.join(CACHE_DIR, get_cache_key(url))
    
    try:
        # 检查缓存
        if os.path.exists(cache_file):
            with open(cache_file, 'r') as f:
                return json.load(f)
        
        # 处理本地文件
        if url.startswith('file:'):
            file_path = url.split('file:', 1)[1].strip()
            if not any(file_path.startswith(p) for p in ALLOWED_LOCAL_PATHS):
                raise ValueError(f"禁止访问本地路径: {file_path}")
            
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f]
        
        # 处理远程URL
        else:
            resp = session.get(
                url,
                headers={'User-Agent': USER_AGENT},
                timeout=15
            )
            resp.raise_for_status()
            lines = [line.strip() for line in resp.text.splitlines()]
        
        # 处理规则
        valid_rules = []
        for line in lines:
            normalized = normalize_rule(line)
            if is_valid_rule(normalized):
                valid_rules.append(normalized)
            elif line and not line.startswith(('!', '#')) and line.strip():
                invalid_rules.append(line)
        
        # 写入缓存
        os.makedirs(CACHE_DIR, exist_ok=True)
        with open(cache_file, 'w') as f:
            json.dump((valid_rules, invalid_rules), f)
        
        return valid_rules, invalid_rules
    
    except Exception as e:
        print(f"❌ 源处理失败 [{url}]: {str(e)}")
        return [], []

def generate_stats(rules: List[str]) -> Dict[str, int]:
    """生成规则类型统计"""
    stats = {
        'domain': 0,    # ||example.com^
        'element': 0,   # ##selector
        'regex': 0,     # /regex/
        'whitelist': 0, # @@||example.com^
        'other': 0
    }
    
    for rule in rules:
        if rule.startswith('@@'):
            stats['whitelist'] += 1
        elif rule.startswith('||'):
            stats['domain'] += 1
        elif rule.startswith('##'):
            stats['element'] += 1
        elif rule.startswith('/') and rule.endswith('/'):
            stats['regex'] += 1
        else:
            stats['other'] += 1
            
    return stats

def update_version() -> int:
    """管理语义化版本号"""
    try:
        with open(VERSION_FILE, 'r+') as f:
            version = int(f.read().strip()) + 1
            f.seek(0)
            f.write(str(version))
            return version
    except FileNotFoundError:
        with open(VERSION_FILE, 'w') as f:
            f.write('1')
            return 1

def main():
    # 读取规则源
    with open(RULE_SOURCES_FILE) as f:
        sources = [line.strip() for line in f if line.strip()]
    
    merged_rules: Set[str] = set()
    error_reports = {}
    
    # 并行下载处理
    with ThreadPoolExecutor(max_workers=5) as executor:
        future_map = {executor.submit(download_rules, url): url for url in sources}
        
        for future in as_completed(future_map):
            url = future_map[future]
            try:
                valid_rules, invalid_rules = future.result()
                merged_rules.update(valid_rules)
                if invalid_rules:
                    error_reports[url] = invalid_rules
            except Exception as e:
                print(f"⛔ 严重错误处理源 [{url}]: {str(e)}")
    
    # 错误报告
    if error_reports:
        print("\n⚠️ 无效规则报告")
        for url, rules in error_reports.items():
            print(f"来源: {url} ({len(rules)} 条无效规则)")
            if len(rules) < 5:  # 显示前5条示例
                for r in rules[:5]:
                    print(f"  - {r}")
            print("───")
    
    # 生成排序规则
    sorted_rules = sorted(
        merged_rules,
        key=lambda x: (
            not x.startswith('||'),  # 域名规则优先
            not x.startswith('##'), # 元素规则其次
            x
        )
    )
    
    # 生成统计
    stats = generate_stats(sorted_rules)
    version = update_version()
    
    # 构建文件头
    header = [
        '! Title: Merged AdGuard Filter',
        '! Description: Merged from trusted sources with advanced validation',
        f'! Version: {version}',
        f'! Updated: {datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")}',
        f'! Total rules: {len(sorted_rules)}',
        '! Stats:',
        f'!  - Domain rules: {stats["domain"]}',
        f'!  - Element rules: {stats["element"]}',
        f'!  - Regex rules: {stats["regex"]}',
        f'!  - Whitelist entries: {stats["whitelist"]}',
        '! Homepage: https://github.com/yourusername/yourrepo\n'
    ]
    
    # 写入文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(header))
        f.write('\n'.join(sorted_rules))
    
    print(f"\n✅ 合并完成！版本 v{version}")
    print(f"📊 统计: 域名拦截 {stats['domain']} | 元素隐藏 {stats['element']} | 正则规则 {stats['regex']}")

if __name__ == '__main__':
    main()