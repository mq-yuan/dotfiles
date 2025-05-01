# ~/.config/fish/functions/change_clash_config.fish
function change_clash_config --description 'Edit the clash verge config from chezmoitemplates'

    # check the chezmoi Templates dir
    set -l chezmoitemplates_dir $HOME/.local/share/chezmoi/.chezmoitemplates
    if not test -d $chezmoitemplates_dir
        echo "Error: Chezmoi Templates directory '$chezmoitemplates_dir' does not exit."
        return -1
    end

    # set the default file 
    set script_file "$chezmoitemplates_dir/clash-verge-script.js"
    set profile_file "$chezmoitemplates_dir/clash-verge-profile.yaml"
    if not test -f "$script_file"
        echo "Error: Chezmoi Templates not contain the clash verge script file ($script_file)"
        return -1
    end
    if not test -f "$profile_file"
        echo "Error: Chezmoi Templates not contain the clash verge profile file ($profile_file)"
        return -1
    end

    if test (count $argv) -gt 0
        if test $argv[1] = "profile"
            set target_file $profile_file
        else if test $argv[1] = "script"
            set target_file $script_file
        else
            echo "Not support `$argv[1]`, only support (\'profile\' or \'script\')"
        end
    else
        set target_file $script_file
    end

    nvim $target_file

end
