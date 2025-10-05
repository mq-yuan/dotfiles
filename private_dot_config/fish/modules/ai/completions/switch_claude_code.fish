# ~/.config/fish/completions/switch_claude_code.fish
#
# Fish shell completions for the 'switch_claude_code' function.
# This script dynamically reads providers from the function file.

# Helper function to parse the provider list from the main function file.
# It outputs in 'argument\tdescription' format.
function __switch_claude_code_get_providers
    set -l func_path "$__fish_config_dir/modules/ai/functions/switch_claude_code.fish"
    if not test -f "$func_path"
        return 1
    end

    # Use a robust `while read` loop to find the line, avoiding pipeline issues.
    set -l line
    while read -l current_line
        if string match -q -- '*set -l providers*' "$current_line"
            set line $current_line
            break
        end
    end < "$func_path"

    if test -z "$line"
        return 1
    end

    # Extract all strings between quotes into a list using lookarounds.
    set -l provider_defs (string match -ra '(?<=\\s")[^;]+' -- "$line")

    # For each definition, output the name and a description, separated by a tab.
    for p_def in $provider_defs
        echo $p_def
    end
end

# -c is the command to complete for.
# -n specifies a condition; here, it completes the first argument.
# -f or --no-files prevents file path completion, making the suggestions exclusive.
# -a provides the argument list; descriptions are now provided by the helper function.

complete -c switch_claude_code -n '__fish_is_first_arg' -f -a '(__switch_claude_code_get_providers)' -d 'Provider'
complete -c switch_claude_code -n '__fish_is_first_arg' -f -a 'off' -d 'Disable/clear Anthropic variables'

