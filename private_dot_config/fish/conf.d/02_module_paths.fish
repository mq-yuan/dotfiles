# Prepend module paths to fish_function_path and fish_complete_path
set -l module_root $XDG_CONFIG_HOME/fish/modules

# Check if the directory exists
if test -d $module_root
    # Loop through each directory inside 'modules'
    for module_dir in $module_root/*/
        # Add the 'functions' subdirectory to the function path, if it exists
        if test -d $module_dir/functions
            set -p fish_function_path $module_dir/functions
        end
        # Add the 'completions' subdirectory to the completion path, if it exists
        if test -d $module_dir/completions
            set -p fish_complete_path $module_dir/completions
        end
    end
end
