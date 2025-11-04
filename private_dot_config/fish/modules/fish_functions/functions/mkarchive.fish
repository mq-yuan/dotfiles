# $HOME/.config/fish/modules/fish_functions/functions/mkarchive.fish

function mkarchive --description "Create an archive (zip or tar.gz) of a directory, with exclusions."
    # --- 1. Argument Parsing ---
    argparse -n mkarchive --min-args=0 --max-args=1 \
        'h/help' \
        'f/format=?' \
        'e/exclude=+' \
        'n/name=?' \
        'o/output-dir=?' \
        -- $argv
    or return 1

    # --- 2. Help Message ---
    if set -q _flag_h
        __mkarchive_print_help
        return 0
    end

    # --- 3. Determine Target Directory ---
    set -l target_dir "." # Default to current directory
    if set -q argv[1]
        set target_dir $argv[1]
    end

    if not test -d "$target_dir"
        echo (set_color red)"Error: Target directory '$target_dir' not found."(set_color normal) >&2
        return 1
    end
    # Get absolute path for reliability
    set target_dir (realpath "$target_dir")
    set -l target_basename (basename "$target_dir")

    # --- 4. Determine Archive Format ---
    set -l format "zip" # Default format
    if set -q _flag_format
        if test "$_flag_format" = "zip" -o "$_flag_format" = "tar.gz"
            set format "$_flag_format"
        else
            echo (set_color red)"Error: Invalid format '$_flag_format'. Use 'zip' or 'tar.gz'."(set_color normal) >&2
            return 1
        end
    end

    # --- 5. Determine Archive Name ---
    set -l archive_basename "$target_basename"
    if set -q _flag_name
        set archive_basename "$_flag_name"
    end
    set -l archive_name "$archive_basename.$format"

    # --- 6. Determine Output Directory ---
    set -l output_dir (dirname "$target_dir") # Default to parent directory
    if set -q _flag_output_dir
       set output_dir (realpath "$_flag_output_dir")
       if not test -d "$output_dir"
            echo (set_color red)"Error: Output directory '$output_dir' not found."(set_color normal) >&2
            return 1
       end
    end
    set -l archive_path "$output_dir/$archive_name"

    # Prevent overwriting existing file accidentally (optional, can add a --force flag later)
    if test -e "$archive_path"
        echo (set_color yellow)"Warning: Archive '$archive_path' already exists."(set_color normal)
        read -P "Overwrite? (y/N) " confirm
        if not string match -q -r '^[Yy]$' -- "$confirm"
            echo "Operation cancelled."
            return 0
        end
        rm -f "$archive_path" # Remove if overwrite is confirmed
    end

    # --- 7. Process Exclusions ---
    set -l exclude_opts
    # Add common default exclusions
    set -l default_excludes ".git" ".vscode" "__pycache__" "*.pyc" "*.swp" ".DS_Store" "node_modules"
    # Combine default and user-provided exclusions
    set -l all_excludes $default_excludes $_flag_exclude

    if set -q all_excludes[1] # Check if there are any exclusions
        for item in $all_excludes
            if test "$format" = "zip"
                # zip exclusion patterns need careful handling, '*' often works well for dirs/files
                # We add '/*' to exclude directory contents and the directory itself often
                set -a exclude_opts -x "$item" -x "$item/*"
            else # tar.gz
                set -a exclude_opts --exclude "$item"
            end
        end
        # Remove duplicates just in case (though argparse might handle this)
        set exclude_opts (printf "%s\n" $exclude_opts | sort -u)
    end

    # --- 8. Check Command Availability ---
    set -l archive_cmd
    if test "$format" = "zip"
        set archive_cmd "zip"
    else # tar.gz
        set archive_cmd "tar"
    end
    if not command -v $archive_cmd >/dev/null
        echo (set_color red)"Error: '$archive_cmd' command not found. Please install it."(set_color normal) >&2
        return 1
    end

    # --- 9. Execute Archiving ---
    echo (set_color blue)"[*] Archiving:"(set_color normal)" '$target_basename'"
    echo (set_color blue)"[*] Format:"(set_color normal)"    $format"
    if set -q exclude_opts[1]
        echo (set_color blue)"[*] Excluding:"(set_color normal) (string join ", " $all_excludes)
    end
    echo (set_color blue)"[*] Output:"(set_color normal)"    '$archive_path'"

    set -l original_dir (pwd)
    if not cd "$target_dir"
        echo (set_color red)"Error: Could not change directory to '$target_dir'."(set_color normal) >&2
        return 1
    end

    set -l cmd_status 1 # Default to error status
    if test "$format" = "zip"
        # -r for recursive, -q for quiet
        command zip -qr "$archive_path" . $exclude_opts
        set cmd_status $status
    else # tar.gz
        # -c create, -z gzip, -f file, -v verbose (optional)
        command tar -czf "$archive_path" $exclude_opts .
        set cmd_status $status
    end

    # IMPORTANT: Always change back to the original directory
    cd "$original_dir"

    # --- 10. Report Result ---
    if test $cmd_status -eq 0
        echo (set_color green)"[✓] Successfully created archive: '$archive_path'"(set_color normal)
        # Optional: open the output directory
        # xdg-open "$output_dir" &; or open "$output_dir" on macOS
        return 0
    else
        echo (set_color red)"[!] Error: Archiving failed with status $cmd_status."(set_color normal) >&2
        # Clean up potentially incomplete archive
        rm -f "$archive_path"
        return 1
    end
end

# Helper function for printing help
function __mkarchive_print_help
    echo "Usage: mkarchive [TARGET_DIR] [OPTIONS]"
    echo
    echo "Creates a zip or tar.gz archive of TARGET_DIR (default: current directory)."
    echo "The archive is saved in the parent directory by default."
    echo
    echo "Options:"
    echo "  TARGET_DIR           Directory to archive (optional, defaults to '.')."
    echo "  -f, --format FORMAT  Archive format: 'zip' (default) or 'tar.gz'."
    echo "  -e, --exclude PATTERN Specify patterns to exclude. Can be used multiple times."
    echo "                       Defaults include: .git, .vscode, __pycache__, *.pyc, *.swp, .DS_Store, node_modules"
    echo "  -n, --name NAME      Base name for the archive file (without extension)."
    echo "                       Defaults to the name of TARGET_DIR."
    echo "  -o, --output-dir DIR Directory where the archive file will be saved."
    echo "                       Defaults to the parent directory of TARGET_DIR."
    echo "  -h, --help           Show this help message."
    echo
    echo "Example:"
    echo "  mkarchive my_project -f tar.gz -e build -e '*.log'"
    echo "  (Archives 'my_project' as '../my_project.tar.gz', excluding 'build' dir and log files)"
    echo "  mkarchive -n my_archive_v1"
    echo "  (Archives current dir as '../my_archive_v1.zip')"
end
