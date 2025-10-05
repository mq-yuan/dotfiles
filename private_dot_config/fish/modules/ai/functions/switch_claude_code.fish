# ~/.config/fish/functions/switch_claude_code.fish
# ===============================================
#
# A function to switch Anthropic API configurations.
# Usage:
#   switch_claude_code <provider>  - Switch to a specific provider (e.g., AIHUBMIX, KIMI).
#   switch_claude_code off         - Disable Anthropic variables.
#   switch_claude_code             - Show current status and usage.

function switch_claude_code --description "Switches ANTHROPIC environment variables among different providers."
    # --- Configuration ---
    # Add new providers here.
    # Format: "PROVIDER_NAME;API_KEY_VARIABLE_NAME;BASE_URL_VARIABLE_NAME"
    set -l providers "AIHUBMIX;AIHUBMIX_API_KEY;AIHUBMIX_BASE_URL" "KIMI;KIMI_API_KEY;KIMI_BASE_URL_FOR_ANTHROPIC"

    # --- Colors ---
    set -l color_green (set_color green)
    set -l color_yellow (set_color yellow)
    set -l color_red (set_color red)
    set -l color_cyan (set_color cyan)
    set -l color_bold (set_color -o)
    set -l color_reset (set_color normal)

    # --- Helper Function ---
    function _switch_to_provider
        set -l provider_name $argv[1]
        set -l key_var_name $argv[2]
        set -l url_var_name $argv[3]

        # Dereference variable names to get their actual values
        set -l api_key $$key_var_name
        set -l base_url $$url_var_name

        if test -z "$api_key" -o -z "$base_url"
            echo -e "$color_red✗ Error:$color_reset Failed to switch to $color_bold$provider_name$color_reset."
            echo -e "  Please ensure $color_cyan$key_var_name$color_reset and $color_cyan$url_var_name$color_reset are set in $color_yellow~/.config/fish/.api_keys.fish$color_reset" >&2
            return 1
        end

        set -gx ANTHROPIC_API_KEY "$api_key"
        set -gx ANTHROPIC_BASE_URL "$base_url"
        echo -e "$color_green✓ Switched to $color_bold$provider_name$color_reset service."
        echo -e "  $color_yellow- URL:$color_reset $base_url"
    end

    # --- Main Logic ---
    if test -f "$HOME/.config/fish/.api_keys.fish"
        source "$HOME/.config/fish/.api_keys.fish"
    else
        echo -e "$color_red✗ Error:$color_reset API key file not found at $color_yellow~/.config/fish/.api_keys.fish$color_reset" >&2
        return 1
    end

    set -l target_provider (string upper -- "$argv[1]")

    switch "$target_provider"
        case "OFF" "DISABLE" "CLEAR"
            echo -e "$color_yellow- Disabling Anthropic environment variables...$color_reset"
            set -e ANTHROPIC_API_KEY
            set -e ANTHROPIC_BASE_URL
            echo -e "$color_green✓ Anthropic variables cleared.$color_reset"

        case "" # No arguments, show status
            set -l provider_names
            for p in $providers; set -a provider_names (string split ";" -- $p)[1]; end

            printf '%sUsage:%s switch_claude_code [ %s%s%s | %s'off'%s ]\n' \
                $color_bold $color_reset \
                $color_green (string join ' | ' $provider_names) $color_reset \
                $color_yellow $color_reset
            echo ""
            echo -e "$color_boldCurrent Status:$color_reset"

            if not set -q ANTHROPIC_BASE_URL
                echo -e "  $color_red✗ Anthropic variables are not set.$color_reset"
                return 1
            end

            set -l current_url $ANTHROPIC_BASE_URL
            set -l active_provider "Unknown"
            for p in $providers
                set -l parts (string split ";" -- $p)
                set -l provider_name $parts[1]
                set -l url_var_name $parts[3]
                if test "$current_url" = "$$url_var_name"
                    set active_provider $provider_name
                    break
                end
            end

            if test "$active_provider" != "Unknown"
                echo -e "  $color_green✓ Active Provider:$color_reset $color_bold$active_provider$color_reset"
            else
                echo -e "  $color_yellow- Provider:$color_reset Custom or Unknown"
            end
            echo -e "  $color_cyan- URL:$color_reset $ANTHROPIC_BASE_URL"
            echo -e "  $color_cyan- KEY:$color_reset Set"


        case "*" # Match a provider
            for p in $providers
                set -l parts (string split ";" -- $p)
                set -l provider_name $parts[1]
                if test "$target_provider" = "$provider_name"
                    _switch_to_provider $parts[1] $parts[2] $parts[3]
                    return 0 # Success
                end
            end

            echo -e "$color_red✗ Error:$color_reset Unknown provider '$color_bold$argv[1]$color_reset'." >&2
            return 1
    end
end
