# $HOME/.config/fish/modules/font_install/functions/font_install.fish

function font_install -d "Install a font from a local ZIP file"

    # --- 1. Argument Parsing ---
    argparse 'n/name=' 'd/delete-source' -- $argv
    or return 1

    set -l zip_path $argv[1]

    # --- 2. Input Validation ---
    if test -z "$zip_path"
        echo "Error: You must provide a path to a local font ZIP file." >&2
        echo "Usage: font_install [--name <name>] [--delete-source] <filepath>" >&2
        return 1
    end

    if not test -f "$zip_path"
        echo "Error: File not found at '$zip_path'." >&2
        return 1
    end

    if not string match -qi "*.zip" "$zip_path"
        echo "Error: Provided file '$zip_path' is not a ZIP file." >&2
        return 1
    end

    # --- 3. Variable Derivation ---
    set -l zip_name (basename "$zip_path")
    set -l font_dir_name

    if set -q _flag_name
        set font_dir_name "$_flag_name"
        echo "Info: Using custom font name: '$font_dir_name'"
    else
        set font_dir_name (string replace -r '(?i)[\-_]?(?:nerd|nf|font|v[0-9].*|[0-9.]+)\.zip$' '' "$zip_name")
        echo "Info: Auto-detected font name as: '$font_dir_name'"
    end

    set -l dest_dir "$HOME/.local/share/fonts/$font_dir_name"

    # --- 4. Prerequisite & Idempotency Checks ---
    if not command -v unzip >/dev/null
        echo "Error: This script requires 'unzip'. Please install it first." >&2
        return 1
    end

    if test -d "$dest_dir"
        echo "Warning: Font '$font_dir_name' appears to be already installed. Skipping." >&2
        return 0
    end

    # --- 5. Core Installation ---
    set -l stage_dir (mktemp -d)
    echo "Info: Created temporary staging directory: $stage_dir"

    function _cleanup
        if test -d "$stage_dir"
            echo "Info: Cleaning up staging directory..."
            rm -rf "$stage_dir"
        end
    end

    echo "Info: Unzipping '$zip_name' to staging directory..."
    if not unzip -q "$zip_path" -d "$stage_dir"
        echo "Error: Unzip failed." >&2
        _cleanup
        return 1
    end

    # --- 6. Structure Normalization ---
    set -l source_content_dir "$stage_dir"
    set -l items_in_stage (ls "$stage_dir")
    if test (count $items_in_stage) -eq 1
        set -l single_item_path "$stage_dir/$items_in_stage[1]"
        if test -d "$single_item_path"
            echo "Info: Detected a single nested directory; using it as the source."
            set source_content_dir "$single_item_path"
        end
    end

    echo "Info: Installing font '$font_dir_name' from '$zip_name'..."
    mkdir -p "$dest_dir"
    if not mv "$source_content_dir"/* "$dest_dir/"
        echo "Error: Failed to move files from staging to destination." >&2
        rm -rf "$dest_dir" # Clean up failed destination directory
        _cleanup
        return 1
    end

    # --- 7. Finalization & Cleanup ---
    _cleanup # Clean up the now-empty staging directory

    echo "Info: Updating system font cache..."
    fc-cache -f -s

    # --- 8. Source File Cleanup ---
    if set -q _flag_delete_source
        echo "Info: Deleting source file as requested by --delete-source flag..."
        if rm "$zip_path"
            echo "  Successfully deleted '$zip_path'"
        else
            echo "Warning: Failed to delete source file '$zip_path'." >&2
        end
    else
        read -P "Do you want to delete the original source file '$zip_path'? [y/N] " confirm
        if string match -q -r '^[Yy]$' -- "$confirm"
            echo "Info: Deleting source file..."
            if rm "$zip_path"
                echo "  Successfully deleted '$zip_path'"
            else
                echo "Warning: Failed to delete source file '$zip_path'." >&2
            end
        end
    end

    # --- 9. Verification ---
    echo ""
    if fc-list | string match -q --quiet --ignore-case "*$font_dir_name*"
        echo "Success: Font '$font_dir_name' was installed successfully."
    else
        echo "Warning: Font files were installed, but 'fc-list' could not find the font immediately." >&2
        echo "  You may need to restart your terminal or run 'fish_reload'." >&2
    end

    return 0
end