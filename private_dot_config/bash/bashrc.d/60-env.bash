# User environment.
. "$HOME/.local/bin/env"

export CC="/usr/bin/gcc-11"
export CXX="/usr/bin/g++-11"

export TARTANGROUND_ROOT="/media/nas/volume1/Workspace/public/datasets/20251115_theairlabcmu__TartanGround/output"

# Training.
export TORCH_NCCL_ASYNC_ERROR_HANDLING=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
