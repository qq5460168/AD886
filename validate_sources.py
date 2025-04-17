import os
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import urlparse
import requests
from hashlib import md5

# 配置参数
SOURCES_FILE = 'sources.txt'
CACHE_DIR = 'source_cache'
CACHE_TTL = 3600  # 缓存有效期（秒）
USER_AGENT = 'MergedFilterValidator/1.0 (+https://github.com/yourusername/yourrepo)'
TIMEOUT = (3.05, 10)
RETRY_STATUS = [429, 500, 502, 503, 504]
MAX_WORKERS = 10

def get_cache_key(url):
    """生成基于URL的缓存文件名"""
    return md5(url.encode()).hexdigest() + ".json"

def validate_source(url):
    """验证单个规则来源"""
    try:
        start_time = time.time()
        resp = requests.get(url, headers={'User-Agent': USER_AGENT}, timeout=TIMEOUT)
        resp.close()
        return {
            'valid': resp.status_code == 200,
            'status': resp.status_code,
            'latency': round(time.time() - start_time, 2),
            'error': None
        }
    except Exception as e:
        return {
            'valid': False,
            'status': None,
            'latency': None,
            'error': str(e)
        }

def main():
    print("📋 验证规则来源")
    with open(SOURCES_FILE, 'r', encoding='utf-8') as f:
        sources = [line.strip() for line in f if line.strip()]

    results = []
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_url = {executor.submit(validate_source, url): url for url in sources}
        for future in as_completed(future_to_url):
            url = future_to_url[future]
            try:
                result = future.result()
                results.append((url, result))
            except Exception as e:
                print(f"⚠️ 验证失败: {url} - {str(e)}")

    for url, result in results:
        if not result['valid']:
            print(f"❌ 无效来源: {url} (Error: {result['error']})")
        else:
            print(f"✅ 验证通过: {url} (Status: {result['status']}, Latency: {result['latency']}s)")

if __name__ == "__main__":
    main()