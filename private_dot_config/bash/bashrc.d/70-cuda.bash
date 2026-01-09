# CUDA multi-version env.

# CUDA 11.8
CUDA11_HOME="/usr/local/cuda-11.8"
CUDNN11_ROOT="$HOME/cuda/cudnn-8.9.7_cuda-11"

# CUDA 12.8
CUDA12_HOME="$HOME/cuda/cuda-12.8"
CUDNN12_ROOT="$HOME/cuda/cudnn-9.8.0_cuda-12"

# Save original env.
if [ -z "${_CUDA_ENV_INITIALIZED:-}" ]; then
    _CUDA_ORIG_PATH="$PATH"
    _CUDA_ORIG_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
    _CUDA_ORIG_CPATH="${CPATH:-}"
    _CUDA_ENV_INITIALIZED=1
fi

cuda() {
    local version="$1"

    case "$version" in
        11.8)
            CUDA_HOME="$CUDA11_HOME"
            CUDNN_ROOT="$CUDNN11_ROOT"
            ;;
        12.8)
            CUDA_HOME="$CUDA12_HOME"
            CUDNN_ROOT="$CUDNN12_ROOT"
            ;;
        *)
            echo "Unknown CUDA version: $version"
            return 1
            ;;
    esac

    # Recover.
    PATH="$_CUDA_ORIG_PATH"
    LD_LIBRARY_PATH="$_CUDA_ORIG_LD_LIBRARY_PATH"
    CPATH="$_CUDA_ORIG_CPATH"

    if [ -d "$CUDA_HOME/bin" ]; then
        PATH="$CUDA_HOME/bin:$PATH"
    fi

    if [ -d "$CUDA_HOME/lib64" ]; then
        LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}"
    elif [ -d "$CUDA_HOME/lib" ]; then
        LD_LIBRARY_PATH="$CUDA_HOME/lib:${LD_LIBRARY_PATH:-}"
    fi

    if [ -d "$CUDA_HOME/include" ]; then
        CPATH="$CUDA_HOME/include:${CPATH:-}"
    fi

    if [ -d "$CUDNN_ROOT/lib" ]; then
        LD_LIBRARY_PATH="$CUDNN_ROOT/lib:${LD_LIBRARY_PATH:-}"
    elif [ -d "$CUDNN_ROOT/lib64" ]; then
        LD_LIBRARY_PATH="$CUDNN_ROOT/lib64:${LD_LIBRARY_PATH:-}"
    fi

    if [ -d "$CUDNN_ROOT/include" ]; then
        CPATH="$CUDNN_ROOT/include:${CPATH:-}"
    fi

    export CUDA_HOME CUDNN_ROOT PATH LD_LIBRARY_PATH CPATH
}

cuda 12.8
