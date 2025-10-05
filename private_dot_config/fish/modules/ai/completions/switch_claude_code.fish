# ~/.config/fish/completions/switch_claude_code.fish
#
# Fish shell completions for the 'switch_claude_code' function.

# -c 是要补全的命令名
# -n '__fish_use_subcommand' 是一个条件，表示在需要子命令时才进行补全
# -a '...' 是参数列表
# -d '...' 是对参数的描述

complete -c switch_claude_code -n '__fish_use_subcommand' -a 'AIHUBMIX' -d 'Use AIHUBMIX as the provider'
complete -c switch_claude_code -n '__fish_use_subcommand' -a 'KIMI' -d 'Use KIMI as the provider'
complete -c switch_claude_code -n '__fish_use_subcommand' -a 'off' -d 'Disable/clear Anthropic variables'
