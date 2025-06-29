import os
import re
import argparse
import time
from PIL import Image

# 尝试导入tqdm，如果失败则提供安装指导
try:
    from tqdm import tqdm
except ImportError:
    print("错误: 未找到 'tqdm' 库。")
    print("请通过命令 'pip install tqdm' 来安装它，以启用进度条功能。")
    exit()

def resize_images_professional(input_dir, output_dir, scale_factor, regex_pattern=None):
    """
    以专业的用户体验处理图片缩放任务。
    - 阶段1: 快速扫描并建立待处理文件列表。
    - 阶段2: 使用tqdm进度条进行图片处理，提供实时反馈和ETA。
    """

    # --- 阶段 1: 文件发现与筛选 ---
    print("🔍 [阶段 1/2] 正在扫描目录并筛选文件...")

    files_to_process = []
    if regex_pattern:
        compiled_regex = re.compile(regex_pattern)

    for root, _, filenames in os.walk(input_dir):
        for filename in filenames:
            # 如果提供了正则表达式，则进行匹配
            if regex_pattern:
                if not compiled_regex.search(filename):
                    continue  # 不匹配则跳过

            # 将符合条件的文件的完整路径添加到列表
            files_to_process.append(os.path.join(root, filename))

    if not files_to_process:
        print("\n⚠️ 未找到任何符合条件的文件。请检查您的输入目录和正则表达式。")
        return

    print(f"✅ 找到 {len(files_to_process)} 个待处理的文件。")
    print("\n🚀 [阶段 2/2] 开始处理图片...")
    time.sleep(1) # 短暂暂停，让用户看清信息

    # --- 阶段 2: 图片处理（带tqdm进度条） ---
    processed_count = 0
    skipped_count = 0

    # 使用tqdm包装文件列表，自动生成进度条
    with tqdm(total=len(files_to_process), desc="调整图片尺寸", unit="张", ncols=100, bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}{postfix}]') as pbar:
        for input_path in files_to_process:
            try:
                # 从完整的输入路径推导出输出路径
                relative_path = os.path.relpath(os.path.dirname(input_path), input_dir)
                filename = os.path.basename(input_path)

                current_output_dir = os.path.join(output_dir, relative_path)
                os.makedirs(current_output_dir, exist_ok=True)
                output_path = os.path.join(current_output_dir, filename)

                # --- 核心图片处理逻辑 ---
                with Image.open(input_path) as img:
                    if img.format is None:
                        # 使用tqdm.write打印，避免弄乱进度条
                        tqdm.write(f"🟡 警告: '{filename}' 不是有效图片格式，已跳过。")
                        skipped_count += 1
                        continue

                    width, height = img.size
                    new_width = round(width * scale_factor)
                    new_height = round(height * scale_factor)

                    resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                    resized_img.save(output_path)

                    processed_count += 1

            except Exception as e:
                # 使用tqdm.write打印错误信息
                tqdm.write(f"🔴 错误: 处理 '{filename}' 时发生错误: {e}")
                skipped_count += 1
            finally:
                # 无论成功失败，都更新进度条
                pbar.update(1)

    # --- 最终报告 ---
    print("\n--- ✨ 处理报告 ✨ ---")
    print(f"✔️ 成功处理: {processed_count} 张图片")
    print(f"❌ 跳过或失败: {skipped_count} 个文件")
    print(f"📂 所有文件已保存至: {os.path.abspath(output_dir)}")
    print("----------------------")


def main():
    """主函数，用于解析命令行参数。"""
    parser = argparse.ArgumentParser(
        description="一个功能强大的图片尺寸调整工具，支持递归处理和正则表达式过滤。",
        formatter_class=argparse.RawTextHelpFormatter
    )
    # ... (命令行参数部分与上一版完全相同，无需修改)
    parser.add_argument("input_dir", help="包含图片的输入目录。")
    parser.add_argument("output_dir", help="用于保存已调整尺寸图片的输出目录。")
    parser.add_argument("--scale", "-s", type=float, required=True, help="图片的缩放比例。\n> 1.0  放大 (例如 2.0 表示放大到2倍)\n< 1.0  缩小 (例如 0.5 表示缩小到一半)")
    parser.add_argument("--regex", "-r", type=str, default=None, help="【可选】用于筛选文件名的正则表达式。\n如果未提供，将尝试处理所有文件。\n示例:\n"
             "  - 只处理PNG图片: '.*\\.png$'\n"
             "  - 只处理JPG和JPEG图片: '.*\\.(jpg|jpeg)$'\n"
             "  - 只处理名为 'frame_5个数字.png' 的文件: '^frame_\\d{5}\\.png$'")

    args = parser.parse_args()

    # ... (信息打印部分与上一版完全相同，无需修改)
    print("\n--- 🛠️ 配置信息 ---")
    print(f"➡️ 输入目录: {args.input_dir}")
    print(f"⬅️ 输出目录: {args.output_dir}")
    print(f"📏 缩放比例: {args.scale}")
    print(f"🔍 文件筛选正则: {'无 (处理所有可识别的图片)' if args.regex is None else args.regex}")
    print("----------------------\n")

    resize_images_professional(args.input_dir, args.output_dir, args.scale, args.regex)

    print("🎉 所有任务已完成！")


if __name__ == "__main__":
    main()
