# ~/.config/fish/modules/apply_template/completions/apply_template.fish

function __fish_get_template_paths
    set -l base_dir $HOME/.config/templates
    set -l token (commandline -ct)
    
    # Get the directory part of the current token for searching
    set -l search_dir (dirname "$token")
    if [ "$search_dir" = "." ]
        set search_dir ""
    end

    # Call the unified helper function to get completion items
    set -l items (__apply_template_get_items "$search_dir")
    
    for item_name in $items
        set -l completion_value "$search_dir"
        # Ensure a trailing slash when not in the root
        if test -n "$completion_value"
            set completion_value "$completion_value/"
        end
        set completion_value "$completion_value$item_name"

        if test -d "$base_dir/$completion_value"
            echo "$completion_value/"\t"Category/Directory"
        else
            echo "$completion_value"\t"Template File"
        end
    end
end

# Use the more compatible '__fish_use_subcommand'
complete -c apply_template -n '__fish_use_subcommand' -f -a "(__fish_get_template_paths)"
