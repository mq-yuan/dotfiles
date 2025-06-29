function __fish_get_template_paths
    set -l base_dir $HOME/.config/templates
    set -l token (commandline -ct)
    
    # 获取当前输入 token 的目录部分，用于搜索
    set -l search_dir (dirname "$token")
    if [ "$search_dir" = "." ]
        set search_dir ""
    end

    # 完整搜索路径
    set -l full_search_path "$base_dir/$search_dir"

    # 遍历搜索路径下的所有条目
    for item in "$full_search_path"/*
        # 只处理存在的文件或目录
        if test -e "$item"
            # 构建补全值 (相对于 templates 目录的路径)
            set -l completion_value (string replace "$base_dir/" "" "$item")
            
            # 如果是目录，在补全值后添加斜杠，以提供更好的级联补全体验
            if test -d "$item"
                echo "$completion_value/"\t"Category/Directory"
            else
                echo "$completion_value"\t"Template File"
            end
        end
    end
end

# 使用兼容性更好的 '__fish_use_subcommand'
complete -c apply_template -n '__fish_use_subcommand' -f -a "(__fish_get_template_paths)"
