# rule.py 优化后
import os
import shutil
import sys

def deduplicate_rules():
    try:
        os.chdir(".././")
        for file in os.listdir():
            if file.endswith('.txt') and os.path.isfile(file):
                print(f'🔍 开始处理文件: {file}')
                temp_file = f'{file}.tmp'
                
                # 使用临时文件避免数据丢失
                with open(file, 'r', encoding='utf-8') as f_in, \
                     open(temp_file, 'w', encoding='utf-8') as f_out:
                    unique_lines = set(f_in.readlines())
                    f_out.writelines(sorted(unique_lines))
                
                # 替换原文件前进行备份
                shutil.copyfile(file, f'{file}.bak')
                os.replace(temp_file, file)
                print(f'✅ 完成去重: {file} (备份: {file}.bak)')
                
        print("🎉 所有规则文件处理完成")
    except Exception as e:
        print(f'❌ 发生错误: {str(e)}', file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    deduplicate_rules()