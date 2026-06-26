# $HOME/.config/fish/modules/apply_template/functions/__apply_template_print_suggestions.fish

function __apply_template_print_suggestions --argument-names path --description "Prints available categories/templates under a path"
    set -l color_yellow (set_color yellow)
    set -l color_cyan (set_color cyan)
    set -l color_normal (set_color normal)

    set -l base_dir $HOME/.config/templates

    echo # Add a newline for better formatting

    set -l display_path (string join / (string split / --no-empty $path))
    if [ -z "$display_path" ]
        echo "$color_yellow Available categories are:$color_normal"
    else
        echo "$color_yellow Available options under '$display_path/' are:$color_normal"
    end

    # Call the unified helper function to get the list of items
    set -l items (__apply_template_get_items "$path")
    if test $status -ne 0 -o (count $items) -eq 0
        echo "  (No templates or subcategories found here)" >&2
        return
    end

    for item_name in $items
        # Check if the item is a directory to apply color
        if test -d "$base_dir/$path/$item_name"
            echo "  - $color_cyan$item_name/$color_normal"
        else
            echo "  - $item_name"
        end
    end
end
