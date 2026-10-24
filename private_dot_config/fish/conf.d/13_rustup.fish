if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# Load rustup's own fish completions dynamically so they stay in sync with the
# installed toolchain version. Replaces a stale vendored snapshot that used to
# live at modules/rustup/completions/rustup.fish.
if command -q rustup
    rustup completions fish | source
end
