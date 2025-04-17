#!/usr/bin/env python3
import os
import re
import requests
import json
from datetime import datetime
import pytz

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'
OUTPUT_FILE = 'merged-filter.txt'
STATS_FILE = 'rule_stats.json'
LOG_FILE = 'error.log'
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
    valid_rules = []
    try:
        if url.startswith('file:'):
            file_path = url.split('file:')[1].strip()
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f]
        else:
            resp = requests.get(url, headers={'User-Agent': USER_AGENT}, timeout=15)
            resp.raise_for_status()
            lines = [line.strip() for line in resp.text.splitlines()]

        for line in lines:
            if is_valid_rule(line):
                valid_rules.append(line)
            else:
                if line and not (REGEX_PATTERNS["comment"].match(line) or REGEX_PATTERNS["blank"].match(line)):
                    invalid_rules.append(line)
    except Exception as e:
        print(f"⚠️ 下载失败: {url} - {str(e)}")
    return valid_rules, invalid_rules

def write_stats(rule_count):
    """写入规则统计信息到 JSON 文件"""
    stats = {
        "rule_count": rule_count,
        "last_update": datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    }
    with open(STATS_FILE, 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=4)
    print(f"✅ 已更新统计信息: {STATS_FILE}")

def generate_header(rule_count):
    """生成文件头部信息"""
    utc_time = datetime.now(pytz.timezone('UTC'))
    beijing_time = utc_time.astimezone(pytz.timezone('Asia/Shanghai')).strftime('%Y-%m-%d %H:%M:%S')
    header = (
        f"[个人合并 2.0]\n"
        f"! Title: 去广告规则，酷安反馈反馈\n"
        f"! Homepage: https://github.com/qq5460168/666\n"
        f"! Expires: 12 Hours\n"
        f"! Version: {beijing_time}（北京时间）\n"
        f"! Description: 适用于AdGuard的去广告规则，合并优质上游规则并去重整理排列\n"
        f"! Total count: {rule_count}\n\n"
    )
    return header

def main():
    print("📂 开始处理规则文件")
    merged_rules = set()
    error_reports = {}

    # 清空日志文件
    if os.path.exists(LOG_FILE):
        open(LOG_FILE, 'w').close()

    with open(RULE_SOURCES_FILE, 'r', encoding='utf-8') as f:
        sources = [line.strip() for line in f if line.strip()]

    for url in sources:
        print(f"📥 正在处理: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)

        if invalid_rules:
            error_reports[url] = invalid_rules
            with open(LOG_FILE, 'a', encoding='utf-8') as log_file:
                log_file.write(f"⚠️ 来自 {url} 的无效规则:\n")
                log_file.write("\n".join(invalid_rules) + "\n\n")
            print(f"  ⚠️ 发现 {len(invalid_rules)} 条无效规则")

    # 排序规则
    sorted_rules = sorted(merged_rules, key=lambda x: (
        not x.startswith('||'),
        not x.startswith('##'),
        x
    ))

    # 生成文件头部
    header = generate_header(len(merged_rules))

    # 写入到输出文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(header)  # 写入头部
        f.write('\n'.join(sorted_rules))
    print(f"✅ 规则合并完成，输出到 {OUTPUT_FILE}")

    # 写入统计信息
    write_stats(len(merged_rules))

if __name__ == "__main__":
    main()