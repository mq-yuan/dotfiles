# $HOME/.config/fish/conf.d/01-env.fish

# set AI tools env
if test -f $HOME/.config/fish/.api_keys.fish
    source $HOME/.config/fish/.api_keys.fish
end

# -- AI Hub Mix --
set --global --export AIHUBMIX_API_KEY $AIHUBMIX_API_KEY
