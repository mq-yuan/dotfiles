#!/bin/bash

# 声明一个数组来存放所有文件路径
declare -a files

# 使用 mapfile (或 readarray) 一次性读取所有找到的文件到数组中
# -print0 和 -d '' 配合使用可以完美处理包含空格或特殊字符的文件名
mapfile -d '' -t files < <(find cam*/ -maxdepth 1 -type f -name '*.jpg' -print0 | sort -z)

# 现在我们有了一个包含所有文件的完整列表，开始循环处理
i=0
for f in "${files[@]}"; do
    # 从完整路径中提取出目录名
    d=$(dirname "$f")

    new_name=$(printf "pass_%05d.jpg" "$i")
    echo "Renaming $f to $d/$new_name"
    mv "$f" "$d/$new_name"
    i=$((i + 1))
done

echo "Renaming complete."
