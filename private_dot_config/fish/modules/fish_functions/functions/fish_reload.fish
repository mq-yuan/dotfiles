# $HOME/.config/fish/functions/fish_reload.fish
function fish_reload --description 'Reloads the shell by replacing the current process with a new login shell' 
  exec $SHELL -l
end
