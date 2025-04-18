- name: Run merge script
  run: |
    python merge_rules.py
    echo "规则更新时间: $(date -u '+%Y-%m-%d %H:%M:%S')" >> update.log
    # 检查文件是否生成
    ls -la merged-filter.txt update.log