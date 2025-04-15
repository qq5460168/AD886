# 🛡️ AD Guard 合并规则库

**一个自动聚合、去重、验证的多源广告拦截规则库，支持 AdGuard/uBlock Origin 等工具。**

[![GitHub Actions Status](https://img.shields.io/github/actions/workflow/status/qq5460168/AD886/update-rules.yml?label=每日自动更新&logo=github)](https://github.com/qq5460168/AD886/actions)
[![规则统计](https://img.shields.io/badge/规则总数-动态更新中-blue)](https://raw.githubusercontent.com/qq5460168/AD886/main/merged-filter.txt)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📥 快速订阅

选择适合你的订阅方式（每日 UTC 0 点自动更新）：

| 订阅类型          | 链接                                                                                       |
|-------------------|------------------------------------------------------------------------------------------|
| GitHub 原始链接    | [点击订阅](https://raw.githubusercontent.com/qq5460168/AD886/main/merged-filter.txt)       |
| 国内加速镜像       | [点击订阅](https://ghproxy.net/https://raw.githubusercontent.com/qq5460168/AD886/main/merged-filter.txt) |

---

## 🌟 项目特性

- **多源聚合**：自动合并 [sources.txt](sources.txt) 中配置的规则源
- **智能过滤**：剔除无效规则、注释和重复条目
- **分类排序**：优先处理域名拦截规则 (`||example.com^`)，其次元素隐藏规则 (`##.ad-banner`)
- **每日更新**：通过 GitHub Actions 自动维护（[查看工作流](.github/workflows/update-rules.yml)）
- **透明报告**：记录[更新日志](update.log)和[无效规则统计](report.md)

---

## 🛠️ 本地使用

### 环境要求
- Python 3.10+
- `requests` 库

### 手动运行
```bash
git clone https://github.com/qq5460168/AD886.git
cd AD886
pip install -r requirements.txt
python merge_rules.py
```

生成文件：
- `merged-filter.txt`: 合并后的规则文件
- `update.log`: 带时间戳的更新记录
- 错误规则报告会在控制台输出

---

## 🤝 参与贡献

### 提交新规则
请通过 [规则提案模板](report.md) 提交 Issue，需包含：
- 规则用途说明
- 触发场景截图
- 开发者工具网络请求记录

### 新增规则源
编辑 [sources.txt](sources.txt)，需满足：
- 每个源独占一行
- 支持 HTTP/HTTPS 或本地文件 (`file:/path/to/rules.txt`)
- 源需包含至少 50 条有效规则（[验证工具](validate_sources.py)）

---

## 📊 数据统计

| 指标              | 详情                          |
|-------------------|------------------------------|
| 最后更新时间       | ![最后更新](https://img.shields.io/github/last-commit/qq5460168/AD886?label=) |
| 规则类型分布       | 动态生成图表（建设中）         |
| 历史更新记录       | [查看日志](update.log)        |

---

## 📜 许可证

本项目采用 [MIT License](LICENSE)，您可以：
- 自由使用、修改和分发代码
- 需保留原始许可证声明
- 不得用于违法用途

---

## ❓ 常见问题

**Q：如何验证规则是否生效？**  
A：在 AdGuard 的「筛选器日志」中搜索目标域名。

**Q：为什么有些广告未被拦截？**  
A：可能是新出现的广告或规则需要调整，请[提交 Issue](report.md)。

**Q：如何紧急更新规则？**  
A：访问 [GitHub Actions 面板](https://github.com/qq5460168/AD886/actions) 手动触发工作流。