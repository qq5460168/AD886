# title.py 优化后
import datetime
import pytz
import glob
import sys

def inject_metadata():
    try:
        beijing_tz = pytz.timezone('Asia/Shanghai')
        beijing_time = datetime.datetime.now(beijing_tz).strftime('%Y-%m-%d %H:%M:%S')
        
        for file_path in glob.glob('./*.txt'):
            if 'whitelist' in file_path:  # 跳过白名单文件
                continue
            
            with open(file_path, 'r+', encoding='utf-8') as f:
                content = f.read()
                line_count = content.count('\n') + 1
                f.seek(0)
                header = (
                    f"[个人合并 2.0]\n"
                    f"! Title: 去广告规则 - 酷安反馈优化\n"
                    f"! Homepage: https://github.com/qq5460168/666\n"
                    f"! Expires: 12 Hours\n"
                    f"! Version: {beijing_time}（北京时间）\n"
                    f"! Description: 适用于AdGuard的去广告规则，合并优质上游规则并去重整理排列\n"
                    f"! Total count: {line_count}\n\n"
                )
                f.write(header + content)
                print(f'📄 已更新文件头部: {file_path}')
                
    except Exception as e:
        print(f'❌ 注入元数据失败: {str(e)}', file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    inject_metadata()