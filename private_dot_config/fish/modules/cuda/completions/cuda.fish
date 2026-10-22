# $HOME/.config/fish/modules/cuda/completions/cuda.fish

complete -c cuda -f -a "(ls (__cuda_base) 2>/dev/null | grep '^cuda-' | string replace 'cuda-' '') latest"
