# $HOME/.config/fish/modules/font_install/functions/font_install.fish

function install_font -d "Install a font from a local ZIP file"

    # --- 1. 参数解析 ---
    # -n/--name: 可选，用于指定字体目录名
    # -d/--delete-source: 可选，一个开关标志，用于在安装成功后删除源 zip 文件
    # 剩下的 argv[1] 将被视为必须的本地 zip 文件路径
    argparse 'n/name=' 'd/delete-source' -- $argv
    if test $status -ne 0
        return 1
    end

    set -l zip_path $argv[1]

    # --- 2. 输入验证 ---
    if test -z "$zip_path"
        echo (set_color red)"错误：你必须提供一个本地字体 ZIP 文件的路径。"(set_color normal)
        echo "用法: install_font [--name <名称>] [--delete-source] <文件路径>"
        return 1
    end

    if not test -f "$zip_path"
        echo (set_color red)"错误：文件不存在于 '$zip_path'。"(set_color normal)
        return 1
    end

    # 使用 -i 忽略大小写，兼容 .zip 和 .ZIP
    if not string match -qi "*.zip" "$zip_path"
        echo (set_color red)"错误：提供的文件 '$zip_path' 不是一个 ZIP 文件。"(set_color normal)
        return 1
    end

    # --- 3. 智能变量派生 ---
    set -l zip_name (basename "$zip_path")
    set -l font_dir_name

    if set -q _flag_name
        set font_dir_name "$_flag_name"
        echo "  -> 使用了自定义字体名称：'$font_dir_name'"
    else
        set font_dir_name (string replace -r '(?i)[\-_]?(?:nerd|nf|font|v[0-9].*|[0-9.]+)\.zip$' '' "$zip_name")
        echo "  -> 智能识别字体名称为：'$font_dir_name'"
    end

    set -l dest_dir "$HOME/.local/share/fonts/$font_dir_name"

    # --- 4. 健壮性与幂等性检查 ---
    if not command -v unzip >/dev/null
        echo (set_color red)"错误：此脚本需要 'unzip'。请先安装它。"(set_color normal)
        return 1
    end

    if test -d "$dest_dir"
        echo (set_color yellow)"字体 '$font_dir_name' 似乎已经安装。"(set_color normal)
        echo "操作已跳过。"
        return 0
    end

    # --- 5. 核心安装流程 ---
    echo (set_color blue)"正在从 '$zip_name' 安装字体 '$font_dir_name'..."(set_color normal)

    echo "  -> 正在解压字体文件到 $dest_dir"
    mkdir -p "$dest_dir"
    if not unzip -q "$zip_path" -d "$dest_dir"
        echo (set_color red)"错误：解压失败。"(set_color normal)
        rm -rf "$dest_dir" # 清理创建失败的目录
        return 1
    end

    # --- 6. 收尾与清理 ---
    echo "  -> 正在更新系统字体缓存..."
    fc-cache -f -s

    # 新增功能：如果用户指定了 --delete-source，则删除源文件
    if set -q _flag_delete_source
        echo "  -> 正在清理源文件..."
        if rm "$zip_path"
            echo "     已成功删除 '$zip_path'"
        else
            echo (set_color red)"     警告：未能删除源文件 '$zip_path'。"(set_color normal)
        end
    end

    # --- 7. 最终验证 ---
    echo ""
    if fc-list | string match -q --quiet --ignore-case "*$font_dir_name*"
        echo (set_color green)"🎉 成功！字体 '$font_dir_name' 已成功安装。"(set_color normal)
    else
        echo (set_color red)"⚠️ 警告：字体文件已安装，但 'fc-list' 未能立即找到它。"(set_color normal)
        echo "   请尝试重启终端或执行 'fish_reload'。"
    end

    return 0
end
