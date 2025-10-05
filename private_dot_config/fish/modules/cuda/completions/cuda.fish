# $HOME/.config/fish/modules/cuda/completions/cuda.fish

complete -c cuda -f -a "(ls $HOME/cuda | grep '^cuda-' | string replace 'cuda-' '') latest"
