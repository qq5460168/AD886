#!/usr/bin/env python3

import os
import re
import requests
import json
from datetime import datetime

# 配置参数
RULE_SOURCES_FILE = 'sources.txt'          # 规则来源文件
OUTPUT_FILE = 'merged-filter.txt'         # 输出文件
STATS_FILE = 'rule_stats.json'            # 统计文件
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
TITLE = "Merged Rules"                    # 标题
VERSION = "1.0.0"                         # 版本号

# 正则表达式模块化
REGEX_PATTERNS = {
    "comment": re.compile(r'^[!#]'),  # 注释行
    "blank": re.compile(r'^\s*$'),  # 空行
    "domain": re.compile(r'^(@@)?(\|\|)?([a-zA-Z0-9-*_.]+)(\^|\$|/)?'),
    "element": re.compile(r'##.+'),  # 元素规则
    "regex_rule": re.compile(r'^/.*/$'),  # 正则规则
    "modifier": re.compile(r'\$(~?[\w-]+(=[^,\s]+)?(,~?[\w-]+(=[^,\s]+)?)*)$')
}

def is_valid_rule(line):
    """
    验证规则有效性
    :param line: 规则行
    :return: 是否有效
    """
    if REGEX_PATTERNS["comment"].match(line) or REGEX_PATTERNS["blank"].match(line):
        return False
    return any(
        pattern.match(line)
        for pattern in [REGEX_PATTERNS["domain"], REGEX_PATTERNS["element"], 
                        REGEX_PATTERNS["regex_rule"], REGEX_PATTERNS["modifier"]]
    )

def download_rules(url):
    """
    下载规则并验证
    :param url: 规则来源 URL 或本地文件路径
    :return: (有效规则列表, 无效规则列表)
    """
    valid_rules, invalid_rules = [], []
    try:
        lines = []
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
            elif line and not REGEX_PATTERNS["comment"].match(line) and not REGEX_PATTERNS["blank"].match(line):
                invalid_rules.append(line)

    except requests.exceptions.RequestException as e:
        print(f"⚠️ 下载失败: {url} - {str(e)}")
    except FileNotFoundError:
        print(f"⚠️ 本地文件未找到: {url}")
    except Exception as e:
        print(f"⚠️ 未知错误: {url} - {str(e)}")

    return valid_rules, invalid_rules

def write_stats(rule_count, total_count, title, version):
    """
    写入规则统计信息到 JSON 文件
    :param rule_count: 有效规则数
    :param total_count: 总规则数
    :param title: 标题
    :param version: 版本号
    """
    stats = {
        "rule_count": rule_count,
        "total_count": total_count,
        "title": title,
        "version": version,
        "last_update": datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    }
    with open(STATS_FILE, 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=4)
    print(f"✅ 已更新统计信息: {STATS_FILE}")

def sort_rules(rules):
    """
    对规则进行排序
    :param rules: 规则集合
    :return: 排序后的规则列表
    """
    return sorted(rules, key=lambda x: (
        not x.startswith('||'),  # 优先域名规则
        not x.startswith('##'),  # 其次是元素规则
        x                        # 最后按字典顺序排序
    ))

def main():
    """
    主函数：处理规则合并、验证和统计
    """
    print("📂 开始处理规则文件")
    merged_rules = set()
    error_reports = {}

    # 检查规则来源文件是否存在
    if not os.path.exists(RULE_SOURCES_FILE):
        print(f"❌ 未找到规则来源文件: {RULE_SOURCES_FILE}")
        return

    # 读取规则来源
    with open(RULE_SOURCES_FILE, 'r', encoding='utf-8') as f:
        sources = [line.strip() for line in f if line.strip()]

    # 下载并验证规则
    for url in sources:
        print(f"📥 正在处理: {url}")
        valid_rules, invalid_rules = download_rules(url)
        merged_rules.update(valid_rules)

        if invalid_rules:
            error_reports[url] = invalid_rules
            print(f"  ⚠️ 发现 {len(invalid_rules)} 条无效规则")

    # 排序规则
    sorted_rules = sort_rules(merged_rules)

    # 写入到输出文件
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sorted_rules))
        f.write(f"\n\n# Total count: {len(sorted_rules)}\n")
        f.write(f"# Title: {TITLE}\n")
        f.write(f"# Version: {VERSION}\n")
    print(f"✅ 规则合并完成，输出到 {OUTPUT_FILE}")

    # 写入统计信息
    write_stats(len(sorted_rules), len(merged_rules), TITLE, VERSION)

    # 输出错误报告
    if error_reports:
        print("\n⚠️ 以下来源存在无效规则:")
        for url, errors in error_reports.items():
            print(f"  - 来源: {url}")
            for error in errors:
                print(f"    - 无效规则: {error}")

if __name__ == "__main__":
    main()