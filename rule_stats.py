import json
from datetime import datetime

def generate_rule_stats(rule_count):
    """生成或更新 rule_stats.json 文件"""
    stats = {
        "rule_count": rule_count,
        "last_update": datetime.utcnow().strftime("%Y-%m-%d")  # 获取当前 UTC 日期
    }

    try:
        # 写入到 rule_stats.json 文件
        with open("rule_stats.json", "w", encoding="utf-8") as f:
            json.dump(stats, f, ensure_ascii=False, indent=4)
        print("✅ rule_stats.json 文件更新成功！")
    except Exception as e:
        print(f"❌ 更新 rule_stats.json 文件失败: {str(e)}")

# 示例：假设规则数量为 12345
generate_rule_stats(12345)