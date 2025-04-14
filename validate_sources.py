import requests

def check_source(url):
    try:
        resp = requests.get(url, timeout=10)
        return resp.status_code == 200
    except:
        return False

with open('sources.txt', 'r') as f:
    sources = [line.strip() for line in f]

invalid_sources = []
for url in sources:
    if not check_source(url):
        invalid_sources.append(url)

if invalid_sources:
    print("以下规则源不可用，建议移除：")
    for url in invalid_sources:
        print(f"- {url}")