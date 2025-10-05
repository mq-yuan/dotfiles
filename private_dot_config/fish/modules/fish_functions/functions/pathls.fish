# $HOME/.config/fish/functions/pathls.fish
function pathls --description 'Lists each directory in the $PATH variable on a new line'
    string split : $PATH
    return 0
end
