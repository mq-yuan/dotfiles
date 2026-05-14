-- WezTerm config for Ubuntu 22.04 workstation (ghostty needs Ubuntu 24+).
-- Located at $XDG_CONFIG_HOME/wezterm/wezterm.lua per XDG Base Directory spec.

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font: match the ghostty setup (Maple Mono NF CN family).
config.font = wezterm.font_with_fallback({
    { family = "Maple Mono NF CN", weight = "Regular" },
    { family = "Noto Color Emoji" },
})
config.font_size = 11.0

-- Color scheme.
config.color_scheme = "Catppuccin Mocha"

-- Cursor: smooth blinking block as a built-in stand-in for ghostty's smear shader.
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseIn"
config.animation_fps = 60
config.max_fps = 120

-- Window chrome: keep system title bar (GNOME on Ubuntu 22.04 looks broken
-- without it), but hide the tab bar when only one tab is open.
config.window_decorations = "TITLE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_padding = {
    left = 8,
    right = 8,
    top = 6,
    bottom = 6,
}

-- Start maximized to mirror kitty's default behavior on this host.
wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- Scrollback and bell.
config.scrollback_lines = 10000
config.audible_bell = "Disabled"

-- Default shell: respect $SHELL (fish on this host).
config.default_prog = { os.getenv("SHELL") or "/usr/bin/fish", "-l" }

return config
