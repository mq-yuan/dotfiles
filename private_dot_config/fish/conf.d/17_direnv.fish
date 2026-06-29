# $HOME/.config/fish/conf.d/17_direnv.fish
# direnv ships on every host now (Brewfile cross-platform). Guard anyway so an
# untagged host that never ran brew bundle doesn't error at shell startup.
if command -q direnv
    direnv hook fish | source
    set -g direnv_fish_mode disable_arrow
end
