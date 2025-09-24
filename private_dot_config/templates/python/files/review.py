# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "beautifulsoup4",
# ]
# ///

import os
import re
from bs4 import BeautifulSoup
from urllib.parse import urlparse
import argparse
import sys
from collections import defaultdict

# --- 配置区 ---

# 1. 可能会暴露身份的敏感链接域名 (主要用于检查HTML文件)
SENSITIVE_LINK_DOMAINS = [
    'github.com',
    'linkedin.com',
    'scholar.google.com',
    'arxiv.org',
    # 你可以添加作者的个人博客或主页域名
    # 'personal-blog.com', 
]

# 2. 可能会暴露身份的敏感词组
POTENTIAL_PHRASES = [
    'acknowledgement',
    'acknowledgements',
    'funded by',
    'grant number',
    'our previous work',
    'contact us',
    'email us',
]

# 3. 需要读取并检查内容的文件的扩展名
TEXT_FILE_EXTENSIONS = ['.html', '.htm', '.js', '.css', '.txt', '.md', '.json']

def review_directory(directory_path, keywords_file):
    """
    主函数，用于遍历和分析指定目录下的文件。
    :param directory_path: 你要审查的项目根目录
    :param keywords_file: 包含作者姓名、单位等关键词的文本文件路径
    """
    if not os.path.isdir(directory_path):
        print(f"[!] 错误: 目录 '{directory_path}' 不存在。请提供一个有效的路径。")
        sys.exit(1)

    print(f"[*] 开始审查目录: {directory_path}\n")
    
    # 读取自定义的关键词
    identifying_keywords = []
    if keywords_file:
        try:
            with open(keywords_file, 'r', encoding='utf-8') as f:
                identifying_keywords = [line.strip().lower() for line in f if line.strip()]
            if identifying_keywords:
                print(f"[+] 成功加载 {len(identifying_keywords)} 个自定义关键词从 '{keywords_file}' 文件。")
        except FileNotFoundError:
            print(f"[!] 错误: 关键词文件 '{keywords_file}' 未找到。")
            # 即使文件找不到，也继续执行其他检查
            pass
    
    # 使用字典来收集每个文件发现的问题
    issues_found = defaultdict(list)

    # 遍历目录下的所有文件
    for root, dirs, files in os.walk(directory_path):
        for filename in files:
            file_path = os.path.join(root, filename)
            
            # --- 审查 A: 文件名 ---
            # 检查文件名（不含扩展名）是否包含敏感关键词
            fname_no_ext = os.path.splitext(filename)[0].lower()
            for keyword in identifying_keywords:
                if keyword in fname_no_ext:
                    # 之前我们讨论过的 luotianyi.jpg 会在这里被标记 (如果你把 luotianyi 加入关键词文件)
                    issues_found[file_path].append(f"文件名包含敏感关键词: '{keyword}'")

            # --- 审查 B: 文件内容 ---
            file_ext = os.path.splitext(filename)[1].lower()
            if file_ext in TEXT_FILE_EXTENSIONS:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                        # 特殊处理 HTML 文件
                        if file_ext in ['.html', '.htm']:
                            soup = BeautifulSoup(content, 'html.parser')
                            text_content = soup.get_text(separator=' ').lower()

                            # 检查敏感链接
                            for link in soup.find_all('a', href=True):
                                href = link['href']
                                if not href or href.startswith('#') or href.startswith('mailto:'):
                                    continue
                                try:
                                    domain = urlparse(href).netloc.lower()
                                    for sensitive_domain in SENSITIVE_LINK_DOMAINS:
                                        if sensitive_domain in domain:
                                            issues_found[file_path].append(f"发现敏感链接: {href}")
                                            break
                                except Exception:
                                    continue
                        else:
                            # 对于其他文本文件 (js, css, etc.)
                            text_content = content.lower()

                        # 检查自定义关键词
                        for keyword in identifying_keywords:
                            if keyword in text_content:
                                issues_found[file_path].append(f"内容包含敏感关键词: '{keyword}'")

                        # 检查电子邮件
                        email_regex = r'[\w\.-]+@[\w\.-]+\.\w+'
                        found_emails = re.findall(email_regex, text_content)
                        if found_emails:
                             for email in found_emails:
                                issues_found[file_path].append(f"发现潜在电子邮件: {email}")

                        # 检查敏感词组
                        for phrase in POTENTIAL_PHRASES:
                            if phrase.lower() in text_content:
                                issues_found[file_path].append(f"内容包含敏感词组: '{phrase}'")

                except UnicodeDecodeError:
                    # 忽略无法用 utf-8 解码的二进制文件
                    pass 
                except Exception as e:
                    issues_found[file_path].append(f"读取或解析文件时出错: {e}")

    # --- 总结报告 ---
    print("\n==================== 审查报告总结 ====================")
    if not issues_found:
        print("\n[✓] 自动审查完成，未在文本文件和文件名中发现明显问题。")
        print("提醒：请务必手动检查图片/视频内容和未扫描的文件！")
    else:
        print(f"\n[!] 在 {len(issues_found)} 个文件中发现潜在问题，请仔细检查：")
        for file_path, problems in issues_found.items():
            # 打印相对路径，使其更简洁
            relative_path = os.path.relpath(file_path, directory_path)
            print(f"\n  -> 文件: {relative_path}")
            for problem in set(problems): # 使用 set 去重
                print(f"     - {problem}")
        print("\n请务必对以上发现的内容进行人工确认和修改。")
    print("\n========================================================")
    print("\n再次强调：本工具不分析图片、视频等二进制文件的内容。最终的人工检查至关重要！")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="一个用于审查本地文件是否违反双盲政策的脚本。",
        epilog="示例: python review_local_files.py --directory ./my_project --keywords-file ./my_keywords.txt"
    )
    parser.add_argument("-d", "--directory", required=True, help="需要审查的项目文件夹路径。")
    parser.add_argument("-k", "--keywords-file", required=True, help="一个文本文件，每行包含一个需要检查的关键词（如作者名、单位名等）。")
    
    args = parser.parse_args()
    
    review_directory(args.directory, args.keywords_file)
