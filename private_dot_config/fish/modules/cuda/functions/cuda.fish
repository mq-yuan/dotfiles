# $HOME/.config/fish/modules/cuda/functions/cuda.fish

# ------------------------------------------------------------------------------
# Main `cuda` function.
# Orchestrates the entire CUDA environment switching process.
# ------------------------------------------------------------------------------
function cuda --description 'Switch between CUDA versions and manage dependencies'
    # --- Configuration ---
    set -l default_version "12.4"
    set -l cuda_base_dir "$HOME/cuda"

    # --- Execution ---
    set -l target_version (__cuda_resolve_version "$default_version" $argv)
    if test $status -ne 0
        return 1
    end

    set -l required_gcc_version (__cuda_get_required_gcc_version "$target_version")
    if test $status -ne 0
        return 1
    end

    if not __cuda_check_and_advise_gcc_switch "$target_version" "$required_gcc_version"
        return 1
    end

    __cuda_update_environment "$cuda_base_dir" "$target_version"
    __cuda_activate_cudnn "$cuda_base_dir" "$target_version"
    __cuda_verify_and_log "$target_version"
end


# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

# Resolves and returns the target CUDA version from user input.
function __cuda_resolve_version --argument-names default_version version_arg
    set -l cuda_base_dir "$HOME/cuda"
    set -l target "$version_arg"
    if test -z "$target"
        set target "$default_version"
    end

    if test "$target" = "latest"
        # First, find the full path of the latest directory.
        set -l latest_dir (ls -d $cuda_base_dir/cuda-* 2>/dev/null | sort -V | tail -n 1)

        # Check if a directory was actually found before processing.
        if test -z "$latest_dir"
            echo "Error: No CUDA installations found in '$cuda_base_dir' to determine 'latest'." >&2
            return 1
        end

        # If found, safely extract the version number.
        set target (basename "$latest_dir" | string replace 'cuda-' '')
    end

    set -l cuda_dir "$cuda_base_dir/cuda-$target"
    if not test -d "$cuda_dir"
        echo "Error: CUDA version '$target' is not found at '$cuda_dir'." >&2
        echo "Available versions:" >&2
        for dir in (ls -d $cuda_base_dir/cuda-* 2>/dev/null)
            if test -d "$dir"
                echo "  - "(basename $dir | string replace 'cuda-' '') >&2
            end
        end
        return 1
    end

    echo "$target"
    return 0
end

# Returns the required GCC version for a given CUDA version.
function __cuda_get_required_gcc_version --argument-names cuda_version
    set -l GCC_COMPATIBILITY_MAP \
        "12.8" "13" \
        "12.4" "13" \
        "11.8" "11"

    for i in (seq 1 2 (count $GCC_COMPATIBILITY_MAP))
        set -l cuda_prefix $GCC_COMPATIBILITY_MAP[$i]
        set -l gcc_version $GCC_COMPATIBILITY_MAP[(math $i+1)]
        
        if string match -q "$cuda_prefix*" "$cuda_version"
            echo "$gcc_version"
            return 0
        end
    end

    echo "Error: Unsupported CUDA version '$cuda_version'. No GCC compatibility rule found." >&2
    echo "Please add a rule to the GCC_COMPATIBILITY_MAP in the script." >&2
    return 1
end

# Checks the current GCC version and advises the user to switch if necessary.
function __cuda_check_and_advise_gcc_switch --argument-names target_version required_gcc
    set -l current_gcc_version (gcc --version | head -n 1 | string match -r '[0-9]+')
    echo "Info: Current GCC major version is $current_gcc_version."
    echo "Info: CUDA $target_version requires GCC $required_gcc."

    if test "$current_gcc_version" != "$required_gcc"
        echo "Warning: GCC version mismatch detected." >&2
        read -P "Attempt to switch GCC version automatically? (y/N) " -l confirm

        if string match -q -r '^[Yy]$' -- "$confirm"
            echo "Info: Attempting to switch GCC with sudo..."
            if test -e "/usr/bin/gcc-$required_gcc"
                sudo update-alternatives --set gcc /usr/bin/gcc-$required_gcc; and sudo update-alternatives --set g++ /usr/bin/g++-$required_gcc
                if test $status -ne 0
                    echo "Error: Failed to switch GCC. Check sudo permissions or if g++-$required_gcc is installed." >&2
                    return 1
                end
                set --global --export CC /usr/bin/gcc-$required_gcc
                set --global --export CXX /usr/bin/g++-$required_gcc
                echo "Info: GCC and G++ switched successfully to version $required_gcc."
                echo "Info: CC and CXX switched successfully to path /usr/bin/gcc-$required_gcc and /usr/bin/g++-$required_gcc."
                return 0 # Continue script
            else
                echo "Error: Required version gcc-$required_gcc is not installed." >&2
                return 1
            end
        else
            echo "Info: Automatic switch declined." >&2
            echo "Please switch your GCC and G++ version manually before proceeding." >&2
            echo "Example command:" >&2
            echo "  sudo update-alternatives --set gcc /usr/bin/gcc-$required_gcc" >&2
            echo "  sudo update-alternatives --set g++ /usr/bin/g++-$required_gcc" >&2
            return 1 # Exit script
        end
    end
    set --global --export CC /usr/bin/gcc-$required_gcc
    set --global --export CXX /usr/bin/g++-$required_gcc
    echo "Info: CC and CXX switched successfully to path /usr/bin/gcc-$required_gcc and /usr/bin/g++-$required_gcc."

    echo "Info: Current GCC version is compatible. No switch needed."
    return 0
end

# Cleans old paths and sets new environment variables for CUDA.
function __cuda_update_environment --argument-names base_dir cuda_version
    echo "Info: Updating environment variables for CUDA $cuda_version..."
    set -l cuda_dir "$base_dir/cuda-$cuda_version"

    function __clean_var --argument-names var_name pattern
        set -l new_value
        for p in $$var_name
            if not string match -q "$pattern" "$p"
                set new_value $new_value $p
            end
        end
        set --global --export $var_name $new_value
    end

    __clean_var PATH "$base_dir/cuda-*"
    __clean_var LD_LIBRARY_PATH "$base_dir/cuda-*"
    __clean_var LD_LIBRARY_PATH "$base_dir/cudnn-*"
    __clean_var CPATH "$base_dir/cuda-*"
    __clean_var CPATH "$base_dir/cudnn-*"

    set --global --export CUDA_HOME "$cuda_dir"
    set --global --export PATH "$cuda_dir/bin" $PATH
    if test -d "$cuda_dir/lib64"
        set --global --export LD_LIBRARY_PATH "$cuda_dir/lib64" $LD_LIBRARY_PATH
    else if test -d "$cuda_dir/lib"
        set --global --export LD_LIBRARY_PATH "$cuda_dir/lib" $LD_LIBRARY_PATH
    end
end

# Finds and activates the latest compatible cuDNN version.
function __cuda_activate_cudnn --argument-names base_dir cuda_version
    echo "Info: Searching for compatible cuDNN..."
    set -l cuda_major (string split '.' $cuda_version | head -n 1)
    
    set -l cudnn_dirs (ls -d $base_dir/cudnn-*_cuda-$cuda_major 2>/dev/null | sort -V)
    if test (count $cudnn_dirs) -eq 0
        echo "Warning: No compatible cuDNN version found for CUDA $cuda_major." >&2
        echo "  Please install cuDNN in a path like: $base_dir/cudnn-<version>_cuda-$cuda_major" >&2
        return
    end

    set -l cudnn_dir $cudnn_dirs[-1]
    set -l cudnn_version (basename $cudnn_dir | string replace -r 'cudnn-(.*)_cuda-.*' '$1')
    echo "Info: Activating latest compatible cuDNN: $cudnn_version"

    if test -d "$cudnn_dir/lib"
        set --global --export LD_LIBRARY_PATH "$cudnn_dir/lib" $LD_LIBRARY_PATH
    else if test -d "$cudnn_dir/lib64"
        set --global --export LD_LIBRARY_PATH "$cudnn_dir/lib64" $LD_LIBRARY_PATH
    end
    set --global --export CPATH "$cudnn_dir/include" $CPATH
end

# Verifies the switch and writes to a log file.
function __cuda_verify_and_log --argument-names cuda_version
    set -l log_dir "$HOME/.log"
    set -l log_path "$log_dir/.cuda_switch.log"
    mkdir -p "$log_dir"

    if type -q nvcc
        set -l current_version (nvcc --version | string match -r 'release \K[0-9]+\.[0-9]+')
        if test "$current_version" = "$cuda_version"
            echo "Success: Switched to CUDA version: $current_version"
            echo "$(date): Switched to CUDA $current_version" >> $log_path
        else
            echo "Error: Switch failed! 'nvcc --version' reports $current_version but expected $cuda_version." >&2
            echo "$(date): Failed to switch to CUDA $cuda_version (version mismatch)" >> $log_path
            return 1
        end
    else
        echo "Error: Switch failed! 'nvcc' command not found." >&2
        echo "Please check if CUDA $cuda_version is correctly installed." >&2
        echo "$(date): Failed to switch to CUDA $cuda_version (nvcc not found)" >> $log_path
        return 1
    end
end
