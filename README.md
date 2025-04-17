import json

README_TEMPLATE = """# 🛡️ AD Guard 合并规则库

**一个自动聚合、去重、验证的多源广告拦截规则库，支持 AdGuard/uBlock Origin 等工具。**

[![GitHub Actions Status](https://img.shields.io/github/actions/workflow/status/qq5460168/AD886/update-rules.yml?label=每日自动更新&logo=github)](https://github.com/qq5460168/AD886/actions)
[![规则统计](https://img.shields.io/badge/规则总数-{rule_count}-blue)](https://raw.githubusercontent.com/qq5460168/AD886/main/merged-filter.txt)

---

## 📊 数据统计

| 指标              | 详情                          |
|-------------------|------------------------------|
| 最后更新时间       | {last_update}                 |
| 当前规则总数       | {rule_count}                  |

---

## 📥 快速订阅

选择适合你的订阅方式（每日 UTC 0 点自动更新）：

| 订阅类型          | 链接                                                                                       |
|-------------------|------------------------------------------------------------------------------------------|
| GitHub 原始链接    | [点击订阅](https://raw.githubusercontent.com/qq5460168/AD886/main/merged-filter.txt)       |
| 国内加速镜像       | [点击订阅](https://ghproxy.net/https://raw.githubusercontent.com/qq5460168/AD886/main/merged-filter.txt) |

---
"""

def update_readme():
    """更新 README.md 文件"""
    try:
        with open("rule_stats.json", 'r', encoding='utf-8') as f:
            stats = json.load(f)
            rule_count = stats.get("rule_count", "未知")
            last_update = stats.get("last_update", "未知")

        readme_content = README_TEMPLATE.format(rule_count=rule_count, last_update=last_update)

        with open("README.md", 'w', encoding='utf-8') as f:
            f.write(readme_content)
        print("✅ README.md 更新成功！")
    except Exception as e:
        print(f"❌ 更新 README.md 失败: {str(e)}")

if __name__ == "__main__":
    update_readme()