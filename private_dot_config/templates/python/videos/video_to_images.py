import os
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
    import numpy as np
except ImportError:
    print("错误: 未找到 'numpy' 库。")
    print("它是进行精确帧计算所必需的，请通过命令 'pip install numpy' 来安装它。")
    exit()

try:
    from tqdm import tqdm
except ImportError:
    print("错误: 未找到 'tqdm' 库。")
    print("请通过命令 'pip install tqdm' 来安装它，以启用进度条功能。")
    exit()


def extract_frames_professional(
    input_video,
    output_dir,
    output_format,
    fps_to_extract=None,
    total_frames=None,
    start_number=1,
    padding=None,
):
    """
    以专业的用户体验和优化的性能处理视频抽帧任务。
    - 阶段1: 分析视频、计算抽帧计划。
    - 阶段2: 通过单次顺序读取视频流高效提取帧，并使用tqdm进度条提供实时反馈。
    """

    # --- 阶段 1: 视频分析与准备 ---
    print("🔍 [阶段 1/2] 正在分析视频并计算抽帧计划...")

    if not os.path.exists(input_video):
        print(f"\n🔴 错误: 输入的视频文件不存在: {input_video}")
        return

    cap = cv2.VideoCapture(input_video)
    if not cap.isOpened():
        print(
            f"\n🔴 错误: 无法打开视频文件: {input_video}。可能文件已损坏或格式不支持。"
        )
        return

    video_total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    video_fps = cap.get(cv2.CAP_PROP_FPS)

    os.makedirs(output_dir, exist_ok=True)

    # --- 计算需要提取的帧索引 ---
    if fps_to_extract:
        if video_fps <= 0:
            print(f"\n🔴 错误: 无法读取源视频的FPS信息，无法使用 --fps 模式。")
            cap.release()
            return
        frame_step = video_fps / fps_to_extract
        frame_indices = np.arange(0, video_total_frames, frame_step).astype(int)
    elif total_frames:
        frame_indices = np.linspace(0, video_total_frames - 1, total_frames, dtype=int)
    else:
        print("\n🔴 错误: 必须指定一个抽帧模式 (--fps 或 --frames)。")
        cap.release()
        return

    # --- 使用Set进行O(1)复杂度的快速查找，这是性能优化的关键 ---
    frames_to_extract_set = set(frame_indices)
    num_frames_to_extract = len(frames_to_extract_set)

    if num_frames_to_extract == 0:
        print("\n⚠️ 根据您的设置，计算出需要提取的帧数为 0。请检查参数。")
        cap.release()
        return

    # --- 决定补零宽度 ---
    if padding is not None:
        padding_width = padding
    else:
        last_number = start_number + num_frames_to_extract - 1
        padding_width = len(str(last_number))

    print(f"✅ 分析完成: 将从视频中提取 {num_frames_to_extract} 帧。")
    print("\n🚀 [阶段 2/2] 开始提取帧 (已启用性能优化)...")
    time.sleep(1)

    # --- 阶段 2: 高效提取帧 ---
    current_frame_index = 0
    saved_count = 0

    with tqdm(
        total=num_frames_to_extract,
        desc="提取视频帧",
        unit="帧",
        ncols=100,
        bar_format="{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}{postfix}]",
    ) as pbar:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break  # 视频读取完毕或发生错误

            # 检查当前帧是否是我们需要保存的目标
            if current_frame_index in frames_to_extract_set:
                sequence_number = start_number + saved_count
                formatted_number = str(sequence_number).zfill(padding_width)
                formatted_filename = output_format.format(i=formatted_number)
                output_path = os.path.join(output_dir, formatted_filename)

                cv2.imwrite(output_path, frame)

                saved_count += 1
                pbar.update(1)

                # 如果已保存所有需要的帧，提前退出循环
                if saved_count == num_frames_to_extract:
                    break

            current_frame_index += 1

    cap.release()

    # --- 最终报告 ---
    print("\n--- ✨ 处理报告 ✨ ---")
    if saved_count < num_frames_to_extract:
        print(
            f"🟡 警告: 计划提取 {num_frames_to_extract} 帧, 但因视频提前结束只成功提取了 {saved_count} 帧。"
        )
    else:
        print(f"✔️ 成功提取: {saved_count} 帧")
    print(f"📂 所有图片已保存至: {os.path.abspath(output_dir)}")
    print("----------------------")


def main():
    """主函数，用于解析命令行参数。"""
    parser = argparse.ArgumentParser(
        description="一个强大的视频抽帧工具，支持按帧率或总帧数进行均匀抽帧，并提供灵活的命名选项。",
        formatter_class=argparse.RawTextHelpFormatter,
    )

    # --- 位置参数 ---
    parser.add_argument("input_video", help="待处理的视频文件路径。")
    parser.add_argument("output_dir", help="用于保存所提取图片的输出目录。")

    # --- 抽帧模式参数 (互斥) ---
    extraction_group = parser.add_mutually_exclusive_group(required=True)
    extraction_group.add_argument(
        "--fps",
        type=float,
        help="指定输出的帧率 (每秒提取的图片数量)。\n"
        "例如: --fps 2 将从视频中每秒提取2张图片。",
    )
    extraction_group.add_argument(
        "--frames",
        type=int,
        help="指定总共要从整个视频中提取的图片总数。\n"
        "程序将会在视频时长内均匀选取对应数量的帧。",
    )

    # --- 命名格式参数 ---
    naming_group = parser.add_argument_group("文件名格式化选项")
    naming_group.add_argument(
        "--format",
        type=str,
        default="frame_{i}.png",
        help="【可选】输出图片的文件名格式 (默认为: 'frame_{i}.png')。\n"
        "使用 `{i}` 作为最终生成的、带补零的序号占位符。\n"
        "示例: 'img_{i}.jpg' -> img_001.jpg, img_002.jpg...",
    )
    naming_group.add_argument(
        "--start-number",
        type=int,
        default=1,
        help="【可选】指定文件名中序号的起始数字 (默认为: 1)。\n"
        "示例: --start-number 101 将使第一个文件序号为 101。",
    )
    naming_group.add_argument(
        "--padding",
        type=int,
        default=None,
        help="【可选】手动指定序号的补零宽度。\n"
        "示例: --padding 5 将会把序号 '1' 格式化为 '00001'。\n"
        "如果未设置，脚本将根据提取总数和起始序号自动计算最佳宽度。",
    )

    args = parser.parse_args()

    # --- 配置信息打印 ---
    print("\n--- 🛠️ 配置信息 ---")
    print(f"➡️ 输入视频: {args.input_video}")
    print(f"⬅️ 输出目录: {args.output_dir}")
    if args.fps:
        print(f"⚙️ 抽帧模式: 按帧率提取 ({args.fps} FPS)")
    if args.frames:
        print(f"⚙️ 抽帧模式: 按总数提取 ({args.frames} 帧)")
    print(f"🏷️ 命名格式: {args.format}")
    print(f"🔢 起始序号: {args.start_number}")
    if args.padding is not None:
        print(f"0️⃣ 数字宽度: 手动指定为 {args.padding} 位")
    else:
        print(f"0️⃣ 数字宽度: 自动计算")
    print("----------------------\n")

    extract_frames_professional(
        args.input_video,
        args.output_dir,
        args.format,
        fps_to_extract=args.fps,
        total_frames=args.frames,
        start_number=args.start_number,
        padding=args.padding,
    )

    print("🎉 所有任务已完成！")


if __name__ == "__main__":
    main()
