def count_rules(file_path):
    """统计有效规则数量"""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return sum(1 for line in f 
                      if line.strip() 
                      and not line.startswith(('#', '!', '/')) 
                      and not line.startswith('@@'))
    except FileNotFoundError:
        print(f"❌ 文件未找到: {file_path}")
        return 0

def generate_rule_stats(count):
    """生成规则统计文件"""
    stats = {
        "rule_count": count,
        "last_updated": datetime.now().isoformat()
    }
    with open("rule_stats.json", "w", encoding="utf-8") as f:
        json.dump(stats, f, indent=2)
    print(f"✅ 生成统计文件: rule_stats.json")

if __name__ == "__main__":
    count = count_rules("merged-filter.txt")
    generate_rule_stats(count)