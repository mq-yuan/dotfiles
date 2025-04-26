# ~/.config/fish/config.fish

# Because I have move all config to conf.d, so we should'n load this file again.
if status is-interactive; and status current-command | string match -q "source"
    echo "please run `fish_reload` to reload fish config, not use `source $HOME/.config/fish/config.fish`."
end

