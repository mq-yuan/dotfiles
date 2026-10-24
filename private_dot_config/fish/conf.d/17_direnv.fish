# $HOME/.config/fish/conf.d/17_direnv.fish
# direnv ships on every host (pacman on Arch, brew on macOS). Guard anyway so a
# host that never installed it doesn't error at shell startup.
if command -q direnv
    direnv hook fish | source
    set -g direnv_fish_mode disable_arrow
end
