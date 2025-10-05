# ~/.config/fish/functions/fish_reload.fish
function fish_reload --description 'reload the fish all config include `config.fish` and other files(such as `conf.d/`)' 
  exec $SHELL -l
end
