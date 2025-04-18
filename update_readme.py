#!/bin/sh

# 获取合并规则的数量
if [ -f "merged-filter.txt" ]; then
    num_rules=$(sed -n 's/^! Total count: //p' merged-filter.txt)
else
    echo "Error: merged-filter.txt not found!" >&2
    exit 1
fi

# 获取当前时间（北京时间）
time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')

# 更新README.md中的更新时间
if [ -f "README.md" ]; then
    sed -i "s/^更新时间:.*/更新时间: $time （北京时间） /g" README.md
    sed -i "s/^拦截规则数量:.*/拦截规则数量: $num_rules /g" README.md
else
    echo "Error: README.md not found!" >&2
    exit 1
fi

# 成功退出
exit 0