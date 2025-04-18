def count_rules(file_path):
    """统计规则文件的行数"""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        # 过滤掉空行和注释行
        rule_count = sum(1 for line in lines if line.strip() and not line.startswith("#"))
        return rule_count
    except FileNotFoundError:
        print(f"❌ 文件未找到: {file_path}")
        return 0

# 示例：统计规则文件 merged-filter.txt 的规则数量
rule_count = count_rules("merged-filter.txt")
generate_rule_stats(rule_count)