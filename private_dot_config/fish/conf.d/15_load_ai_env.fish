# $HOME/.config/fish/conf.d/15_load_ai_env.fish
# Source the KeepassXC-rendered AI provider env file. The file itself lives
# outside conf.d (so fish does not autoload it) and exports its own vars.

if test -f $HOME/.config/fish/.api_keys.fish
    source $HOME/.config/fish/.api_keys.fish
end
