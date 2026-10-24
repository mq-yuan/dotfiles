# $HOME/.config/fish/modules/cuda/functions/__cuda_base.fish
#
# Single knob for the CUDA/cuDNN/OptiX install location. Override with
# CUDA_ROOT if a machine keeps toolchains elsewhere; default $HOME/cuda.
function __cuda_base
    if set -q CUDA_ROOT
        echo $CUDA_ROOT
    else
        echo $HOME/cuda
    end
end
