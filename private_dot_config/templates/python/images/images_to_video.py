# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "opencv-python",
#     "pillow",
#     "tqdm",
# ]
# ///
import os
import re
import argparse
import time

# 尝试导入所需库，如果失败则提供安装指导
try:
    import cv2
except ImportError:
    print("错误: 未找到 'opencv-python' 库。")
    print("它是处理视频的核心库，请通过命令 'pip install opencv-python' 来安装它。")
    exit()

try:
    from PIL import Image
except ImportError:
    print("错误: 未找到 'Pillow' 库。")
    print("它用于安全地读取图片尺寸，请通过命令 'pip install Pillow' 来安装它。")
    exit()

try:
    from tqdm import tqdm
except ImportError:
    print("错误: 未找到 'tqdm' 库。")
    print("请通过命令 'pip install tqdm' 来安装它，以启用进度条功能。")
    exit()


def natural_sort_key(s):
    """为字符串提供自然排序的键，例如 'img10.jpg' 会在 'img2.jpg' 之后。"""
    return [int(text) if text.isdigit() else text.lower() for text in re.split('([0-9]+)', s)]


def create_video_from_images(
    input_dir,
    output_video_path,
    regex_pattern=None,
    fps=None,
    duration=None,
    recursive=False,
    overwrite=False,
):
    """
    以专业的用户体验将图片序列转换为视频。
    - 阶段1: 扫描、筛选并排序图片文件，确定视频参数。
    - 阶段2: 使用tqdm进度条进行视频编码，提供实时反馈。
    """

    # --- 阶段 0: 安全检查 ---
    if os.path.exists(output_video_path) and not overwrite:
        print(f"\n🔴 错误: 输出文件 '{output_video_path}' 已存在。")
        print("为防止意外覆盖，请删除现有文件或使用 --overwrite 标志。")
        return

    # --- 阶段 1: 文件发现与参数计算 ---
    print("🔍 [阶段 1/2] 正在扫描目录、筛选并排序文件...")

    files_to_process = []
    if regex_pattern:
        compiled_regex = re.compile(regex_pattern)

    # 根据是否递归选择不同的文件搜集策略
    if recursive:
        print("   - 启用递归扫描...")
        for root, _, filenames in os.walk(input_dir):
            for filename in filenames:
                if regex_pattern and not compiled_regex.search(filename):
                    continue
                full_path = os.path.join(root, filename)
                files_to_process.append(full_path)
    else:
        for filename in os.listdir(input_dir):
            full_path = os.path.join(input_dir, filename)
            if os.path.isfile(full_path):
                if regex_pattern and not compiled_regex.search(filename):
                    continue
                files_to_process.append(full_path)

    # --- 按文件名进行自然排序，这对于视频序列至关重要 ---
    files_to_process.sort(key=lambda f: natural_sort_key(os.path.basename(f)))

    if not files_to_process:
        print("\n⚠️ 未找到任何符合条件的文件。请检查您的输入目录、正则表达式和--recursive选项。")
        return

    print(f"✅ 找到 {len(files_to_process)} 张符合条件的图片。")

    # --- 确定视频尺寸 ---
    try:
        with Image.open(files_to_process[0]) as img:
            width, height = img.size
        print(f"🖼️ 视频尺寸将设定为第一张图片的尺寸: {width}x{height}。")
    except Exception as e:
        print(f"\n🔴 错误: 无法读取第一张图片 '{files_to_process[0]}' 的尺寸: {e}")
        return

    # --- 计算最终帧率 ---
    if duration:
        if duration <= 0:
            print("\n🔴 错误: --duration 必须是正数。")
            return
        final_fps = len(files_to_process) / duration
        print(f"⏱️ 根据总时长 {duration}s 和 {len(files_to_process)} 帧计算出帧率: {final_fps:.2f} FPS。")
    elif fps:
        final_fps = fps
    else:
        # 这个逻辑理论上不会被触发，因为argparse会强制要求--fps或--duration
        print("\n🔴 错误: 必须指定一个帧率模式 (--fps 或 --duration)。")
        return

    # --- 准备输出 ---
    output_dir = os.path.dirname(output_video_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    print("\n🚀 [阶段 2/2] 开始将图片序列编码为视频...")
    time.sleep(1)

    # --- 阶段 2: 视频编码（带tqdm进度条） ---
    file_extension = os.path.splitext(output_video_path)[1].lower()
    codec_map = {
        '.mp4': 'mp4v',
        '.mov': 'mp4v',
        '.avi': 'XVID',
    }
    codec = codec_map.get(file_extension)
    if not codec:
        print(f"🟡 警告: 未知的视频扩展名 '{file_extension}'。将默认使用 'mp4v' 编码器。")
        codec = 'mp4v'
    else:
        print(f"📹 将为 '{file_extension}' 文件使用 '{codec}' 编码器。")

    fourcc = cv2.VideoWriter_fourcc(*codec)
    video_writer = cv2.VideoWriter(output_video_path, fourcc, final_fps, (width, height))

    if not video_writer.isOpened():
        print(f"\n🔴 错误: 无法初始化 VideoWriter。请检查输出路径、权限和OpenCV安装。")
        return

    processed_count = 0
    with tqdm(total=len(files_to_process), desc="视频编码中", unit="帧", ncols=100, bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}{postfix}]') as pbar:
        for image_path in files_to_process:
            try:
                frame = cv2.imread(image_path)
                if frame is None:
                    tqdm.write(f"🟡 警告: 无法读取图片 '{os.path.basename(image_path)}'，已跳过。")
                    continue
                
                frame_h, frame_w, _ = frame.shape
                if (frame_w, frame_h) != (width, height):
                    tqdm.write(f"🟡 警告: '{os.path.basename(image_path)}' 的尺寸 ({frame_w}x{frame_h}) 与视频尺寸 ({width}x{height}) 不符，将自动缩放。")
                    frame = cv2.resize(frame, (width, height))

                video_writer.write(frame)
                processed_count += 1
            except Exception as e:
                tqdm.write(f"🔴 错误: 处理 '{os.path.basename(image_path)}' 时发生错误: {e}")
            finally:
                pbar.update(1)

    video_writer.release()

    # --- 最终报告 ---
    print("\n--- ✨ 处理报告 ✨ ---")
    print(f"✔️ 成功处理: {processed_count} / {len(files_to_process)} 帧")
    print(f"🎬 视频文件已保存至: {os.path.abspath(output_video_path)}")
    print("----------------------")


def main():
    """主函数，用于解析命令行参数。"""
    parser = argparse.ArgumentParser(
        description="一个功能强大的图片序列转视频工具，支持正则筛选和灵活的帧率控制。",
        formatter_class=argparse.RawTextHelpFormatter
    )

    # --- 位置参数 ---
    parser.add_argument("input_dir", help="包含有序图片序列的输入目录。")
    parser.add_argument("output_video", help="输出视频文件的完整路径 (例如: 'output/my_video.mp4')。")

    # --- 筛选与行为参数 ---
    option_group = parser.add_argument_group("筛选与行为选项")
    option_group.add_argument("--regex", "-r", type=str, default=None, help="""可选】用于筛选文件名的正则表达式。
文件将按自然顺序排序 (例如, 'img2.png' 在 'img10.png' 之前)。
示例: - 只处理PNG图片: '.*.png' 只处理名为 'frame_数字.jpg' 的文件: '^frame_\d+\.jpg$'
""")
    option_group.add_argument("--recursive", "-R", action="store_true", help="【可选】递归地在输入目录的所有子目录中搜索图片。")
    option_group.add_argument("--overwrite", "-f", "--force", action="store_true", help="【可选】如果输出视频文件已存在，则强制覆盖它。 ")


    # --- 帧率控制参数 (互斥) ---
    duration_group = parser.add_mutually_exclusive_group(required=True)
    duration_group.add_argument("--fps", type=float, help="直接指定视频的帧率 (FPS)。")
    duration_group.add_argument("--duration", type=float, help="指定视频的总时长（秒）。 帧率将通过 (总图片数 / 时长) 自动计算。")

    args = parser.parse_args()

    # --- 配置信息打印 ---
    print("\n--- 🛠️ 配置信息 ---")
    print(f"➡️ 输入目录: {args.input_dir}")
    print(f"⬅️ 输出视频: {args.output_video}")
    print(f"🔍 文件筛选正则: {'无' if args.regex is None else args.regex}")
    if args.fps:
        print(f"⚙️ 帧率模式: 固定帧率 ({args.fps} FPS)")
    if args.duration:
        print(f"⚙️ 帧率模式: 固定总时长 ({args.duration}s)")
    print(f"🔄 递归搜索: {'启用' if args.recursive else '禁用'}")
    print(f"💥 强制覆盖: {'启用' if args.overwrite else '禁用'}")
    print("----------------------\n")

    create_video_from_images(
        args.input_dir,
        args.output_video,
        regex_pattern=args.regex,
        fps=args.fps,
        duration=args.duration,
        recursive=args.recursive,
        overwrite=args.overwrite,
    )

    print("🎉 所有任务已完成！")


if __name__ == "__main__":
    main()
