# $HOME/.config/fish/modules/apply_template/functions/apply_template.fish

function apply_template --description "Applies a project template from $HOME/.config/templates"
    # --- Color variables for pretty output ---
    set -l color_red (set_color red)
    set -l color_green (set_color green)
    set -l color_yellow (set_color yellow)
    set -l color_cyan (set_color cyan)
    set -l color_normal (set_color normal)

    # --- Helper function: Print suggestions ---
    function __print_suggestions --argument-names path
        set -l base_dir $HOME/.config/templates

        echo # Add a newline for better formatting
        
        set -l display_path (string join / (string split / --no-empty $path))
        if [ -z "$display_path" ]
            echo "$color_yellowAvailable categories are:$color_normal"
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

    # ----------------------------------
    # --- Main function logic ---
    # ----------------------------------
    set -l base_dir $HOME/.config/templates

    if test -z "$argv[1]"
        echo "$color_red Usage: apply_template <category/subcategory/template>$color_normal" >&2
        __print_suggestions ""
        return 1
    end

    set -l template_path $argv[1]
    set -l parts (string split / --no-empty $template_path)
    set -l depth (count $parts)

    # 1. Strictly check the path depth
    if test $depth -ne 3
        echo "$color_red Error: Invalid path. Templates must be applied from the 3rd level.$color_normal" >&2
        # Find the deepest valid path and provide suggestions
        set -l valid_path ""
        for i in (seq 1 $depth)
            set -l current_check (string join / $parts[1..$i])
            if test -d "$base_dir/$current_check"
                set valid_path $current_check
            else
                # Stop at the first invalid path segment
                break
            end
        end
        __print_suggestions $valid_path
        return 1
    end

    # 2. Validate the path segment by segment
    set -l category_path "$base_dir/$parts[1]"
    set -l subcategory_path "$category_path/$parts[2]"
    set -l source_path "$subcategory_path/$parts[3]"

    if not test -d "$category_path"
        echo "$color_red Error: Category '$parts[1]' not found.$color_normal" >&2
        __print_suggestions ""
        return 1
    end
    if not test -d "$subcategory_path"
        echo "$color_red Error: Subcategory '$parts[2]' not found in '$parts[1]/'.$color_normal" >&2
        __print_suggestions "$parts[1]"
        return 1
    end
    if not test -e "$source_path"
        echo "$color_red Error: Template '$parts[3]' not found in '$parts[1]/$parts[2]/'.$color_normal" >&2
        __print_suggestions "$parts[1]/$parts[2]"
        return 1
    end

    # 3. If everything is correct, perform the copy operation
    set -l dest_name (basename "$source_path")
    if test -e "$dest_name"
        read -P "$color_yellow Warning: '$dest_name' already exists. Overwrite? (y/N) $color_normal" -l confirm
        if not string match -q -r '^[Yy]$' -- "$confirm"
            echo "Operation cancelled."
            return 0
        end
        rm -rf "$dest_name"
    end

    echo -n "Applying template..."
    if test -d "$source_path"
        cp -r "$source_path" .
    else
        cp "$source_path" .
    end
    
    if test $status -eq 0
        echo " $color_green done.$color_normal"
        echo "🚀 Successfully applied template '$dest_name'."
    else
        echo " $color_red error.$color_normal"
        echo "Error: Failed to copy." >&2
        return 1
    end
end
