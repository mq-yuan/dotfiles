# $HOME/.config/fish/functions/install_deb.fish

function install_deb -d "Safely install a .deb package with validation, cleanup, and optional original file deletion"
    # Parse arguments with argparse
    argparse 'y/delete-original' 'n/no-delete' -- $argv
    or return 1

    set auto_delete false
    set skip_delete false
    set deb_file $argv[1]

    if set -q _flag_y
        set auto_delete true
    end
    if set -q _flag_n
        set skip_delete true
    end

    # Validate arguments
    if test -z "$deb_file"
        echo "Usage: install_deb [-y|--delete-original] [-n|--no-delete] <deb-file>"
        echo "  -y, --delete-original: Automatically delete the original .deb file"
        echo "  -n, --no-delete: Skip deletion of the original .deb file"
        return 1
    end

    # Validate file existence and extension
    if not test -f "$deb_file"
        echo "Error: File '$deb_file' does not exist"
        return 1
    end
    if not string match -q "*.deb" "$deb_file"
        echo "Error: '$deb_file' is not a .deb file"
        return 1
    end

    # Create temporary directory with permissive permissions
    set temp_dir (mktemp -d)
    if test $status -ne 0
        echo "Error: Failed to create temporary directory"
        return 1
    end
    chmod 755 "$temp_dir"
    echo "Created temporary directory: $temp_dir"

    # Cleanup function
    function _cleanup 
        set -l temp_dir $argv[1]
        if test -d "$temp_dir"
            echo "Attempting to clean up $temp_dir"
            rm -rf "$temp_dir"
            if test $status -eq 0
                echo "Successfully cleaned up $temp_dir"
            else
                echo "Warning: Failed to clean up $temp_dir (permission issue?)"
            end
        else
            echo "Temporary directory $temp_dir does not exist, no cleanup needed"
        end
    end

    # Copy file to temporary directory
    set temp_deb "$temp_dir/$(basename "$deb_file")"
    if not cp "$deb_file" "$temp_deb"
        _cleanup $temp_dir
        echo "Error: Failed to copy .deb file to temporary directory"
        return 1
    else
        echo "Copied $deb_file to $temp_deb for safe installation"
    end
    chmod 644 "$temp_deb"

    # Verify package integrity
    if not dpkg -I "$temp_deb" >/dev/null
        _cleanup $temp_dir
        echo "Error: Invalid or corrupted .deb file"
        return 1
    end

    # Install package with apt to handle dependencies
    echo "Installing $deb_file..."
    if not sudo apt-get install -y "$temp_deb"
        _cleanup $temp_dir
        echo "Error: Installation failed"
        return 1
    end

    # Clean up temporary directory
    _cleanup $temp_dir

    # Handle original file deletion
    if test "$auto_delete" = true
        rm -f "$deb_file"
        if test $status -eq 0
            echo "Deleted original file $deb_file"
        else
            echo "Warning: Failed to delete $deb_file"
        end
    else if test "$skip_delete" = false
        read -P "Do you want to delete the original file '$deb_file'? [y/N] " response
        if string match -qir '^y$' "$response"
            rm -f "$deb_file"
            if test $status -eq 0
                echo "Deleted original file $deb_file"
            else
                echo "Warning: Failed to delete $deb_file"
            end
        else
            echo "Original file $deb_file preserved"
        end
    else
        echo "Skipping deletion of $deb_file due to -n option"
    end

    echo "Successfully installed $deb_file"
    return 0
end
