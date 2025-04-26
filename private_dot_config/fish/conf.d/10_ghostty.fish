# ~/.config/fish/conf.d/10-ghostty.fish

if set --query GHOSTTY_RESOURCES_DIR
    set --global GHOSTTY_SHELL_INTEGRATION_FEATURES auto-status,graftin,transient-prompt,working-directory
end
