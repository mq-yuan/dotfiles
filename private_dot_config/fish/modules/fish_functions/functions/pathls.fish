# ~/.config/fish/functions/pathls.fish
function pathls
    string split : $PATH
    return 0
end
