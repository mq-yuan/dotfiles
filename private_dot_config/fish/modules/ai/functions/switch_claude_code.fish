# ~/.config/fish/functions/switch_claude_code.fish
# ===============================================
#
# A function to switch Anthropic API configurations.
# Usage:
#   switch_claude_code AIHUBMIX      - Use AIHUBMIX service.
#   switch_claude_code KIMI          - Use KIMI service.
#   switch_claude_code off           - Disable Anthropic variables.
#   switch_claude_code               - Show current status and usage.

function switch_claude_code --description "Switches ANTHROPIC environment variables among different providers."

    # 每次都加载密钥文件，以确保获取到最新的配置
    if test -f "$HOME/.config/fish/.api_keys.fish"
        source "$HOME/.config/fish/.api_keys.fish"
    else
        echo "Error: API key file not found at ~/.config/fish/.api_keys.fish" >&2
        return 1
    end

    # 根据第一个参数进行选择
    switch "$argv[1]"
        case "AIHUBMIX"
            echo "Switching to Anthropic -> (AIHUBMIX) service..."
            set -gx ANTHROPIC_API_KEY $AIHUBMIX_API_KEY
            set -gx ANTHROPIC_BASE_URL $AIHUBMIX_BASE_URL
            echo -e "✓ ANTHROPIC_API_KEY set to aihubmix key."
            echo -e "✓ ANTHROPIC_BASE_URL set to $AIHUBMIX_BASE_URL."

        case "KIMI"
            echo "Switching to Anthropic -> (KIMI) service..."
            set -gx ANTHROPIC_API_KEY $KIMI_API_KEY
            set -gx ANTHROPIC_BASE_URL $KIMI_BASE_URL_FOR_ANTHROPIC
            echo -e "✓ ANTHROPIC_API_KEY set to KIMI key."
            echo -e "✓ ANTHROPIC_BASE_URL set to $KIMI_BASE_URL_FOR_ANTHROPIC."

        case "off" "disable" "clear"
            echo -e "Disabling Anthropic environment variables..."
            set -e ANTHROPIC_API_KEY
            set -e ANTHROPIC_BASE_URL
            echo "✓ Anthropic variables have been cleared."

        case "*" # 匹配其他所有情况，包括没有参数，用于显示帮助和状态
            echo "Usage: switch_claude_code [ AIHUBMIX | KIMI | off ]"
            echo ""
            echo "Current Status:"
            if set -q ANTHROPIC_BASE_URL
                echo -e "  URL:  $ANTHROPIC_BASE_URL"
            else
                echo -e "  URL:  Not Set"
            end
            if set -q ANTHROPIC_API_KEY
                echo -e "  KEY:  Set"
            else
                echo -e "  KEY:  Not Set"
            end
            return 1 # 返回非零状态码，表示没有执行成功切换
    end
end
