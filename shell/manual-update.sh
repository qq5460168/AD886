#!/bin/bash
# 确保脚本在发生错误时退出
set -e

# 验证必要的环境变量是否已设置
if [ -z "$GITHUBTOKEN" ]; then
    echo "Error: GITHUBTOKEN is not set."
    exit 1
fi

# 定义常量以提高可读性
API_URL="https://api.github.com/repos/cats-team/AdRules/dispatches"
EVENT_TYPE="Manual-Update"

# 执行 API 请求
curl -X POST "$API_URL" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUBTOKEN" \
    --data "{\"event_type\": \"$EVENT_TYPE\"}"

echo "Pass"
