# $HOME/.config/fish/completions/apply_uv_template.fish

# 这是一个辅助函数，用于获取所有可用的模板名称
# 将逻辑封装在函数里是良好的实践
function __fish_get_uv_template_names
  set -l template_dir $HOME/.config/templates/uv
  
  # 确保模板目录存在
  if test -d $template_dir
    for file in $template_dir/*.toml
      echo (basename $file .toml)\t"Project Template"
    end
  end
end

# 定义主命令的补全规则
# -c apply_uv_template: 为哪个命令进行补全
# -n '...': 补全触发的条件，这里是“当没有其他参数时”
# -f: 禁止文件路径补全
# -a '...': 指定补全列表的生成方式，这里调用了我们定义的辅助函数
complete -c apply_uv_template -n "not __fish_seen_subcommand_from (__fish_print_main_command)" -f -a "(__fish_get_uv_template_names)"
