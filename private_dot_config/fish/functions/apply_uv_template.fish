# ~/.config/fish/functions/apply_uv_template.fish

function apply_uv_template --description "Apply a uv project template from $HOME/.config/templates/uv"
    # --- 检查是否提供了模板名称 ---
    if test -z "$argv[1]"
        echo "Usage: apply_uv_template <template_name>" >&2
        echo "Example: apply_uv_template 3dgs" >&2
        
        # 如果存在模板文件，列出可用的模板
        set -l template_dir $HOME/.config/templates/uv
        if test -d $template_dir
            echo -e "\nAvailable templates:"
            for file in $template_dir/*.toml
                echo "  - "(basename $file .toml)
            end
        end
        return 1
    end

    set -l template_name $argv[1]
    set -l source_file $HOME/.config/templates/uv/$template_name.toml
    set -l dest_file ./pyproject.toml

    # --- 检查模板文件是否存在 ---
    if not test -f "$source_file"
        echo "Error: Template '$template_name' not found at '$source_file'" >&2
        return 1
    end

    # --- 如果目标文件已存在，请求确认 ---
    if test -f "$dest_file"
        read -P "Warning: 'pyproject.toml' already exists. Overwrite? (y/N) " -l confirm
        # 如果不是 'y' 或 'Y'，则取消操作
        if not string match -q -r '^[Yy]$' -- "$confirm"
            echo "Operation cancelled."
            return 0
        end
    end

    # --- 执行复制操作 ---
    if cp "$source_file" "$dest_file"
        echo "🚀 Successfully applied template '$template_name' to './pyproject.toml'."
    else
        echo "Error: Failed to copy template." >&2
        return 1
    end
end
