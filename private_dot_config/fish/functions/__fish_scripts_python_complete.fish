# ~/.config/fish/functions/__fish_scripts_python_complete.fish
function __fish_scripts_python_complete
    for file in $HOME/Project/scripts/*.py
        test -f "$file" && basename "$file" .py
    end
end
