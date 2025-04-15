import os
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import urlparse
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# 配置参数
SOURCES_FILE = 'sources.txt'
CACHE_DIR = 'source_cache'
CACHE_TTL = 3600  # 1小时缓存有效期
USER_AGENT = 'MergedFilterValidator/1.0 (+https://github.com/yourusername/yourrepo)'
TIMEOUT = (3.05, 10)  # (连接超时, 读取超时)
RETRY_STATUS = [429, 500, 502, 503, 504]
MAX_WORKERS = 10  # 最大并发数

# 初始化带重试的Session
session = requests.Session()
retries = Retry(
    total=3,
    backoff_factor=0.5,
    status_forcelist=RETRY_STATUS,
    allowed_methods=["GET"]
)
session.mount('https://', HTTPAdapter(max_retries=retries))
session.mount('http://', HTTPAdapter(max_retries=retries))

def get_cache_key(url: str) -> str:
    """生成基于URL的缓存文件名"""
    return hashlib.md5(url.encode()).hexdigest() + ".json"

def is_local_file(url: str) -> bool:
    """检查是否为本地文件"""
    return url.startswith('file:')

def validate_remote_source(url: str) -> dict:
    """验证远程规则源有效性"""
    try:
        start_time = time.time()
        resp = session.get(
            url,
            headers={'User-Agent': USER_AGENT},
            timeout=TIMEOUT,
            stream=True  # 仅检查头部
        )
        resp.close()  # 提前关闭连接
        
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

def validate_local_source(url: str) -> dict:
    """验证本地文件有效性"""
    try:
        file_path = url.split('file:', 1)[1].strip()
        if not os.path.exists(file_path):
            return {'valid': False, 'error': 'File not found'}
        
        # 检查文件大小和内容
        stat = os.stat(file_path)
        if stat.st_size == 0:
            return {'valid': False, 'error': 'Empty file'}
        
        with open(file_path, 'r', encoding='utf-8') as f:
            line_count = sum(1 for line in f if line.strip())
            
        return {
            'valid': line_count >= 10,  # 至少包含10行有效内容
            'lines': line_count,
            'error': None
        }
    except Exception as e:
        return {'valid': False, 'error': str(e)}

def validate_source(url: str) -> dict:
    """验证单个规则源"""
    # 检查缓存
    cache_file = os.path.join(CACHE_DIR, get_cache_key(url))
    if os.path.exists(cache_file):
        with open(cache_file, 'r') as f:
            cache_data = json.load(f)
            if time.time() - cache_data['timestamp'] < CACHE_TTL:
                return cache_data
    
    # 执行验证
    result = {
        'url': url,
        'timestamp': time.time(),
        'type': 'local' if is_local_file(url) else 'remote'
    }
    
    if result['type'] == 'local':
        validation = validate_local_source(url)
    else:
        validation = validate_remote_source(url)
    
    result.update(validation)
    
    # 写入缓存
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(cache_file, 'w') as f:
        json.dump(result, f)
    
    return result

def generate_report(results: list) -> str:
    """生成可视化报告"""
    report = []
    valid_count = sum(1 for r in results if r['valid'])
    
    # 汇总统计
    report.append("📊 验证结果汇总")
    report.append(f"✅ 有效源: {valid_count}/{len(results)}")
    report.append(f"❌ 无效源: {len(results)-valid_count}\n")
    
    # 详细报告
    report.append("🔍 详细分析")
    for res in results:
        if res['valid']:
            info = f"✅ [{res['type'].upper()}] {res['url']}"
            if res['type'] == 'remote':
                info += f" | 状态码: {res['status']} | 延迟: {res['latency']}s"
            else:
                info += f" | 有效规则数: {res['lines']}"
        else:
            info = f"❌ [{res['type'].upper()}] {res['url']}"
            if res['error']:
                info += f" | 错误: {res['error']}"
            if res.get('status'):
                info += f" | 状态码: {res['status']}"
        
        report.append(info)
    
    return '\n'.join(report)

def main():
    # 读取规则源
    with open(SOURCES_FILE, 'r') as f:
        sources = [line.strip() for line in f if line.strip()]
    
    # 并发验证
    results = []
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {executor.submit(validate_source, url): url for url in sources}
        
        for future in as_completed(futures):
            url = futures[future]
            try:
                results.append(future.result())
            except Exception as e:
                print(f"验证异常 {url}: {str(e)}")
    
    # 生成报告
    print(generate_report(results))
    
    # 输出需要处理的源
    invalid_sources = [res['url'] for res in results if not res['valid']]
    if invalid_sources:
        print("\n🚨 建议移除以下无效源:")
        for url in invalid_sources:
            print(f"- {url}")

if __name__ == '__main__':
    main()