# $HOME/.config/fish/conf.d/01-env.fish

# set AI tools env
if test -f $HOME/.config/fish/.api_keys.fish
    source $HOME/.config/fish/.api_keys.fish
end

# -- AI Hub Mix --
set --global --export AIHUBMIX_API_KEY $AIHUBMIX_API_KEY

# -- xAI --
set --global --export XAI_API_KEY $XAI_API_KEY

# -- DeepSeek --
set --global --export DEEPSEEK_API_KEY $DEEPSEEK_API_KEY

# -- Anthropic/Claude (or any tool that needs this key) --
set --global --export ANTHROPIC_BASE_URL $KIMI_BASE_URL_FOR_ANTHROPIC
set --global --export ANTHROPIC_API_KEY $KIMI_API_KEY

