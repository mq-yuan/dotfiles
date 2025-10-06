# ~/.config/fish/modules/tools_update/functions/tools_update.fish

# Main function. Acts as the entry point and command-line interface.
function tools_update --description "Updates various development tools."

    # --- 1. Configuration & Tool Definitions ---
    # The tool list is now fetched from the helper function, establishing a Single Source of Truth.
    set -l tools (__tools_update_get_list)

    # --- 2. Command-Line Argument Parsing ---
    # Provides a flexible and powerful CLI.
    set -l options (fish_opt --short=h --long=help)
    set -l options $options (fish_opt --short=a --long=all)
    set -l options $options (fish_opt --short=t --long=type --required-val)
    set -l options $options (fish_opt --short=e --long=exclude --required-val --multiple-vals)
    argparse $options -- $argv
    or return 1

    # Help message
    if set -q _flag_h
        __tools_update_print_help
        return 0
    end

    # --- 3. Tool Selection Logic ---
    # Determines which tools to update based on user flags.
    set -l selected_tools
    if set -q argv[1] # User specified tools by name
        for requested_tool in $argv
            set -l found false
            set -l i 1
            while test $i -le (count $tools)
                set -l name (string lower $tools[$i])
                if string match -q -- "$requested_tool" "$name"
                    # Append the 5 fields for the found tool
                    set -a selected_tools $tools[$i] $tools[(math $i + 1)] $tools[(math $i + 2)] $tools[(math $i + 3)] $tools[(math $i + 4)]
                    set found true
                    break
                end
                set i (math $i + 5)
            end
            if not $found
                echo (set_color red)"Error: Tool '$requested_tool' not found."(set_color normal) >&2
            end
        end
    else # No specific tools named, use flags or default
        set -l excluded_tools $_flag_e
        set -l included_types $_flag_t
        set -l default_types "user" "language" "fish"

        if set -q _flag_a # --all flag
            set included_types "user" "language" "fish" "system"
        else if not set -q included_types[1] # No --type flag
            set included_types $default_types
        end

        set -l i 1
        while test $i -le (count $tools)
            set -l name (string lower $tools[$i])
            set -l check_cmd $tools[(math $i + 1)]
            set -l update_cmd $tools[(math $i + 2)]
            set -l type $tools[(math $i + 3)]
            set -l sudo_req $tools[(math $i + 4)]

            if contains -- "$name" $excluded_tools
                set i (math $i + 5)
                continue
            end

            if contains -- "$type" $included_types
                set -a selected_tools $tools[$i] $check_cmd $update_cmd $type $sudo_req
            end
            
            set i (math $i + 5)
        end
    end

    if not set -q selected_tools[1]
        echo "No tools selected for update."
        return 0
    end

    # --- 4. Sequential Execution Engine ---
    echo "Starting update for selected tools..."
    echo

    # Use a robust `while` loop to process the list of tools.
    set -l i 1
    while test $i -le (count $selected_tools)
        # Take the next 5 elements as the current tool
        set -l name $selected_tools[$i]
        set -l check_cmd $selected_tools[(math $i + 1)]
        set -l update_cmd $selected_tools[(math $i + 2)]
        set -l type $selected_tools[(math $i + 3)]
        set -l sudo_req $selected_tools[(math $i + 4)]

        # Move to the next tool (5 elements forward)
        set i (math $i + 5)

        # Check if the command exists (either as executable or Fish function)
        if not command -v $check_cmd >/dev/null 2>&1; and not type -q $check_cmd
            echo (set_color yellow)"Skipping $name (command '$check_cmd' not found)."(set_color normal)
            echo
            continue
        end

        # Run the update directly (allows interactive prompts like sudo)
        __tools_update_run_single "$name" "$update_cmd" "$sudo_req"
        echo
    end

    # --- 5. Completion Message ---
    echo (set_color green)"All updates finished."(set_color normal)
end


# Helper function to run a single update.
# This is where interactivity (like sudo password prompts) happens.
function __tools_update_run_single --argument-names name command sudo_required
    echo "Starting update for $name..."
    set_color green
    echo "Executing: $command"
    set_color normal
    
    # Directly execute the command. Fish will handle the interactive sudo prompt.
    eval $command
    
    set -l exit_code $status
    if test $exit_code -eq 0
        echo "Finished update for $name successfully."
    else
        set_color red
        echo "Update for $name failed with exit code: $exit_code"
        set_color normal
    end
end


# Helper function to print usage information.
function __tools_update_print_help
    echo "Usage: tools_update [TOOL_NAMES...] [OPTIONS...]"
    echo
    echo "A powerful tool updater."
    echo
    echo "If no tool names are provided, it runs based on options or defaults."
    echo "Default behavior (no flags): Updates all 'user', 'language', and 'fish' type tools."
    echo
    echo "OPTIONS:"
    echo "  -a, --all                Update all defined tools, including system tools."
    echo "  -t, --type <TYPE>        Update all tools of a specific type (e.g., 'language', 'system')."
    echo "  -e, --exclude <NAME>     Exclude a specific tool from the update. Can be used multiple times."
    echo "  -h, --help               Show this help message."
    echo
    echo "AVAILABLE TOOLS:"
    
    # Dynamically generate the tools list from __tools_update_get_list
    set -l tools (__tools_update_get_list)
    set -l i 1
    while test $i -le (count $tools)
        set -l name $tools[$i]
        set -l check_cmd $tools[(math $i + 1)]
        set -l type $tools[(math $i + 3)]
        
        # Format: Name (type) - check_cmd
        printf "  %-20s [%s] - %s\n" "$name" "$type" "$check_cmd"
        
        set i (math $i + 5)
    end
    
    echo
    echo "TOOL TYPES:"
    echo "  user     - User-level package managers (no sudo required)"
    echo "  language - Language-specific tools and package managers"
    echo "  fish     - Fish shell plugins and extensions"
    echo "  system   - System-level package managers (requires sudo)"
end
