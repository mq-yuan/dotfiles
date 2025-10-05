# $HOME/.config/fish/modules/deb_install/functions/deb_install.fish

function deb_install -d "Safely install a .deb package with validation, cleanup, and optional original file deletion"
    # Parse arguments with argparse
    argparse 'y/delete-original' 'n/no-delete' -- $argv
    or return 1

    set -l auto_delete false
    set -l skip_delete false
    set -l deb_file $argv[1]

    if set -q _flag_y
        set auto_delete true
    end
    if set -q _flag_n
        set skip_delete true
    end

    # Validate arguments
    if test -z "$deb_file"
        echo "Usage: deb_install [-y|--delete-original] [-n|--no-delete] <deb-file>" >&2
        echo "  -y, --delete-original: Automatically delete the original .deb file" >&2
        echo "  -n, --no-delete: Skip deletion of the original .deb file" >&2
        return 1
    end

    # Validate file existence and extension
    if not test -f "$deb_file"
        echo "Error: File '$deb_file' does not exist" >&2
        return 1
    end
    if not string match -q "*.deb" "$deb_file"
        echo "Error: '$deb_file' is not a .deb file" >&2
        return 1
    end

    # Create temporary directory
    set -l temp_dir (mktemp -d)
    if test $status -ne 0
        echo "Error: Failed to create temporary directory" >&2
        return 1
    end
    echo "Info: Created temporary directory: $temp_dir"

    # Nested cleanup function for maximum compatibility.
    function _cleanup
        if test -d "$temp_dir"
            echo "Info: Cleaning up temporary directory: $temp_dir"
            rm -rf "$temp_dir"
            if test $status -ne 0
                echo "Warning: Failed to clean up $temp_dir. Manual deletion may be required." >&2
            end
        end
    end

    # Copy file to temporary directory
    set -l temp_deb "$temp_dir/"(basename "$deb_file")
    if not cp "$deb_file" "$temp_deb"
        echo "Error: Failed to copy .deb file to temporary directory" >&2
        _cleanup
        return 1
    end
    echo "Info: Copied $deb_file to $temp_deb for safe installation"

    # Verify package integrity
    if not dpkg -I "$temp_deb" >/dev/null 2>&1
        echo "Error: Invalid or corrupted .deb file" >&2
        _cleanup
        return 1
    end

    # Install package with apt to handle dependencies
    echo "Info: Installing $deb_file..."
    if not sudo apt-get install -y "$temp_deb"
        echo "Error: Installation failed" >&2
        _cleanup
        return 1
    end

    # Final cleanup of temporary directory
    _cleanup

    # Handle original file deletion
    if test "$auto_delete" = true
        rm -f "$deb_file"
        if test $status -eq 0
            echo "Info: Deleted original file $deb_file"
        else
            echo "Warning: Failed to delete $deb_file" >&2
        end
    else if test "$skip_delete" = false
        read -P "Do you want to delete the original file '$deb_file'? [Y/n] " response
        if string match -qir '^[nN]$' -- "$response"
            echo "Info: Original file $deb_file preserved"
        else
            rm -f "$deb_file"
            if test $status -eq 0
                echo "Info: Deleted original file $deb_file"
            else
                echo "Warning: Failed to delete $deb_file" >&2
            end
        end
    else
        echo "Info: Skipping deletion of $deb_file due to -n option"
    end

    echo "Success: Successfully installed $deb_file"
    return 0
end
