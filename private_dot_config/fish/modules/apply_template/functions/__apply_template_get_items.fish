# ~/.config/fish/modules/apply_template/functions/__apply_template_get_items.fish

function __apply_template_get_items --description "Lists items in a given template subdirectory"
    set -l base_dir $HOME/.config/templates
    set -l relative_path $argv[1]
    set -l search_path "$base_dir/$relative_path"

    # If the search path does not exist or is not a directory, return nothing.
    if not test -d "$search_path"
        return 1
    end

    # Iterate and output all entries in the directory.
    for item in "$search_path"/*
        # Only process items that actually exist.
        if test -e "$item"
            # Output only the base name of the item.
            echo (basename "$item")
        end
    end
end
