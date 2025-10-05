# $HOME/.config/fish/conf.d/12_pnpm.fish
set --global --export PNPM_HOME "$HOME/.local/share/pnpm"
fish_add_path $PNPM_HOME
