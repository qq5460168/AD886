#!/bin/bash
set -euo pipefail

MAX_RETRIES=3
RETRY_DELAY=10
ENDPOINT="https://api.github.com/repos/cats-team/AdRules/dispatches"

trigger_update() {
  local attempt=1
  while [[ $attempt -le $MAX_RETRIES ]]; do
    echo "Attempt $attempt: Triggering update..."
    response=$(curl -s -w "%{http_code}\n%{response_headers}" -X POST "$ENDPOINT" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token $GITHUBTOKEN" \
      --data '{"event_type": "Manual-Update"}')
    
    http_code=$(echo "$response" | head -n1)
    headers=$(echo "$response" | tail -n+2)
    
    if [[ $http_code -eq 204 ]]; then
      echo "Trigger successful (HTTP 204)."
      return 0
    else
      echo "Attempt $attempt failed. HTTP code: $http_code"
      
      # 检查速率限制
      rate_limit_remaining=$(echo "$headers" | grep -i "x-ratelimit-remaining" | cut -d' ' -f2)
      if [[ $rate_limit_remaining -eq 0 ]]; then
        rate_limit_reset=$(echo "$headers" | grep -i "x-ratelimit-reset" | cut -d' ' -f2)
        reset_time=$(date -d "@$rate_limit_reset" +'%Y-%m-%d %H:%M:%S')
        echo "Rate limit exceeded. Retry after $reset_time."
        exit 1
      fi
      
      if [[ $attempt -lt $MAX_RETRIES ]]; then
        sleep $RETRY_DELAY
      fi
      ((attempt++))
    fi
  done

  echo "Failed to trigger after $MAX_RETRIES attempts."
  exit 1
}

trigger_update