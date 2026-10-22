# $HOME/.config/fish/modules/cuda/functions/cuda.fish
#
# Opt-in CUDA toolchain activation for the *current* shell only. Projects pin
# their toolchain via direnv (`use cuda <ver>` in .envrc); this command exists
# for ad-hoc work outside a project (scratch nvcc builds, one-off runs).
#
# Deliberately NOT auto-run at startup: no CUDA path ever leaks into the
# global shell or desktop processes. Run `cuda 12.8`, `cuda 11.8`, `cuda latest`.
#
# Layout (see __cuda_base for the base dir):
#   $CUDA_ROOT/cuda-<ver>/            CUDA toolkit
#   $CUDA_ROOT/cudnn-<ver>_cuda-<maj> cuDNN (newest matching the CUDA major)
# OptiX is managed only through direnv (`use optix <ver>`), not here.
function cuda --description 'Activate a CUDA toolchain in the current shell'
    set -l base (__cuda_base)
    set -l target "$argv[1]"
    test -n "$target"; or set target "12.8"

    if test "$target" = "latest"
        set -l latest_dir (find $base -maxdepth 1 -type d -name 'cuda-*' 2>/dev/null | sort -V | tail -n 1)
        if test -z "$latest_dir"
            echo "cuda: no CUDA toolkits found under $base" >&2
            return 1
        end
        set target (basename "$latest_dir" | string replace 'cuda-' '')
    end

    set -l cuda_dir "$base/cuda-$target"
    if not test -d "$cuda_dir"
        echo "cuda: $cuda_dir not found" >&2
        return 1
    end

    # Host compiler. Point CC/CXX/CUDAHOSTCXX at the versioned gcc/g++ that
    # matches this CUDA release (gcc11/gcc13 from AUR on Arch). The system
    # default gcc is left untouched. Missing compiler is a warning, not fatal.
    set -l gcc_ver ""
    switch "$target"
        case '11.8*'
            set gcc_ver 11
        case '12.*'
            set gcc_ver 13
    end
    if test -n "$gcc_ver" -a -x "/usr/bin/gcc-$gcc_ver"
        set -gx CC "/usr/bin/gcc-$gcc_ver"
        set -gx CXX "/usr/bin/g++-$gcc_ver"
        set -gx CUDAHOSTCXX "/usr/bin/g++-$gcc_ver"
    else if test -n "$gcc_ver"
        echo "cuda: warning: /usr/bin/gcc-$gcc_ver not found; host compiler left as-is" >&2
    end

    set -gx CUDA_HOME "$cuda_dir"

    # Drop any previous CUDA/cuDNN entries so re-activation is idempotent.
    for var in PATH LD_LIBRARY_PATH CPATH
        set -l kept
        for p in $$var
            if not string match -q "$base/cuda-*" "$p"; and not string match -q "$base/cudnn-*" "$p"
                set kept $kept "$p"
            end
        end
        set -gx $var $kept
    end

    set -gx PATH "$cuda_dir/bin" $PATH
    if test -d "$cuda_dir/lib64"
        set -gx LD_LIBRARY_PATH "$cuda_dir/lib64" $LD_LIBRARY_PATH
    else if test -d "$cuda_dir/lib"
        set -gx LD_LIBRARY_PATH "$cuda_dir/lib" $LD_LIBRARY_PATH
    end

    # Newest cuDNN matching the CUDA major version.
    set -l major (string split '.' "$target")[1]
    set -l cudnn_dirs (find $base -maxdepth 1 -type d -name "cudnn-*_cuda-$major" 2>/dev/null | sort -V)
    if test (count $cudnn_dirs) -gt 0
        set -l cudnn_dir $cudnn_dirs[-1]
        if test -d "$cudnn_dir/lib"
            set -gx LD_LIBRARY_PATH "$cudnn_dir/lib" $LD_LIBRARY_PATH
        else if test -d "$cudnn_dir/lib64"
            set -gx LD_LIBRARY_PATH "$cudnn_dir/lib64" $LD_LIBRARY_PATH
        end
        test -d "$cudnn_dir/include"; and set -gx CPATH "$cudnn_dir/include" $CPATH
        echo "cuda $target + cudnn "(basename $cudnn_dir | string replace -r 'cudnn-(.*)_cuda-.*' '$1')
    else
        echo "cuda $target (no cudnn for cuda-$major)"
    end
end
