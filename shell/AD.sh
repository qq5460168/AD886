# AD.sh
+#!/usr/bin/env bash
+set -euo pipefail  # 严格错误处理

# 增加证书验证
+wget --ca-certificate=/etc/ssl/certs/ca-certificates.crt \
+     -O "${TARGET_DIR}/AD.txt" \
+     https://raw.githubusercontent.com/qq5460168/666/master/dns.txt