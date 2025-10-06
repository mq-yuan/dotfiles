# ~/.config/fish/modules/tools_update/completions/tools_update.fish

# Helper function to get only the tool names for completion.
function __tools_update_get_tool_names_for_completion
    # Call the single source of truth
    set -l full_list (__tools_update_get_list)
    
    # Extract only the first item of every 5 (the tool's name)
    for i in (seq 1 5 (count $full_list))
        string lower -- $full_list[$i]
    end
end

# Main completion logic
complete -c tools_update -n "__fish_is_first_arg" -f -a '(__tools_update_get_tool_names_for_completion)' -d "Tool to update"

# Command-line flags
complete -c tools_update -s a -l all -d "Update all tools, including system-level"
complete -c tools_update -s h -l help -d "Show help message"

# Flags with required values
complete -c tools_update -s t -l type -f -a "user language fish system" -d "Update a specific type of tool"
complete -c tools_update -s e -l exclude -f -a '(__tools_update_get_tool_names_for_completion)' -d "Exclude a tool from the update"