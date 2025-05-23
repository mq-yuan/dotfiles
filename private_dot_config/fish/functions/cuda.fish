# ~/.config/fish/functions/cuda.fish
function cuda --description 'Switch between CUDA versions'
    # 默认 CUDA 版本
    set default_version "12.4"
    set cuda_base_dir "$HOME/cuda"

    # 获取用户输入的版本号，如果没有提供则使用默认版本
    if test (count $argv) -gt 0
        set target_version $argv[1]
    else
        set target_version $default_version
    end

    # 支持 "latest" 别名
    if test "$target_version" = "latest"
        set target_version (ls -d $cuda_base_dir/cuda-* | sort -V | tail -n 1 | basename | string replace 'cuda-' '')
    end

    # 检查目标 CUDA 目录是否存在
    set cuda_dir "$cuda_base_dir/cuda-$target_version"
    if not test -d "$cuda_dir"
        echo "错误: CUDA 版本 $target_version 不存在！"
        echo "可用的 CUDA 版本："
        for dir in $cuda_base_dir/cuda-*
            if test -d "$dir"
                basename $dir | string replace 'cuda-' ''
            end
        end
        return 1
    end

    # 检测当前 GCC 版本
    set current_gcc_version (gcc --version | head -n 1 | string match -r '[0-9]+\.[0-9]+')
    set gcc_major (string split '.' $current_gcc_version | head -n 1)
    echo "当前 GCC 版本: $current_gcc_version"

    # 根据 CUDA 版本确定所需 GCC 最大版本
    set cuda_major (string split '.' $target_version | head -n 1)
    set cuda_minor (string split '.' $target_version | tail -n 1)
    if test "$cuda_major" -eq 11 -a "$cuda_minor" -ge 8
        set selected_gcc_version "11"  # CUDA 11.8 支持最高 GCC 11.4
    else if test "$cuda_major" -eq 12 -a "$cuda_minor" -lt 8
        set selected_gcc_version "13"  # CUDA 12.0 - 12.8 支持最高 GCC 13.8（根据最新文档更新）
    else if test "$cuda_major" -eq 12 -a "$cuda_minor" -ge 8
        set selected_gcc_version "14"
    else
        echo "不支持的 CUDA 版本: $target_version"
        return 1
    end


    # 检查是否需要切换 GCC
    if test "$gcc_major" != "$selected_gcc_version"
        echo "当前 GCC $current_gcc_version 与目标版本 $selected_gcc_version 不匹配，尝试切换"
        # 优先使用 update-alternatives 切换 GCC
        if test -e "/usr/bin/gcc-$selected_gcc_version"
            sudo update-alternatives --set gcc /usr/bin/gcc-$selected_gcc_version
            sudo update-alternatives --set g++ /usr/bin/g++-$selected_gcc_version
            echo "已通过 update-alternatives 切换到 GCC $selected_gcc_version"
        else
            echo "错误: GCC $selected_gcc_version 未安装，请先安装 gcc-$selected_gcc_version 和 g++-$selected_gcc_version"
            return 1
        end
    else
        echo "当前 GCC $current_gcc_version 已兼容 CUDA $target_version，无需切换"
    end

    # 重置与 CUDA 相关的环境变量
    set new_path
    for p in $PATH
        if not string match -q "$cuda_base_dir/cuda-*" $p
            set new_path $new_path $p
        end
    end
    set --global --export PATH $new_path

    set -l new_ld_path
    for p in $LD_LIBRARY_PATH
        if not string match -q "$cuda_base_dir/cuda-*" $p
            set new_ld_path $new_ld_path $p
        end
    end
    set --global --export LD_LIBRARY_PATH $new_ld_path


    # 设置新的 CUDA 环境变量
    set --global --export CUDA_HOME "$cuda_dir"
    set --global --export PATH "$cuda_dir/bin" $PATH
    if test -d "$cuda_dir/lib"
        set --global --export LD_LIBRARY_PATH "$cuda_dir/lib" $LD_LIBRARY_PATH
    else if test -d "$cuda_dir/lib64"
        set --global --export LD_LIBRARY_PATH "$cuda_dir/lib64" $LD_LIBRARY_PATH
    end

    # 设置新的 CUDNN 环境变量
    # 动态选择 cuDNN 版本
    set cudnn_dirs (ls -d $cuda_base_dir/cudnn-*_cuda-$cuda_major 2>/dev/null | sort -V)
    if test (count $cudnn_dirs) -eq 0
        echo "警告: 未找到任何 cuDNN 版本 for CUDA $cuda_major"
        echo "请安装 cuDNN 到路径如: $cuda_base_dir/cudnn-8.9.7_cuda-$cuda_major"
        echo "推荐版本: CUDA 11.* 使用 cuDNN 8.9.7，CUDA 12.* 使用 cuDNN 9.8.0"
    else
        echo "找到以下 cuDNN 版本 for CUDA $cuda_major："
        for dir in $cudnn_dirs
            set cudnn_version (basename $dir | string replace -r 'cudnn-(.*)_cuda-.*' '$1')
            echo "  - $cudnn_version ($dir)"
        end
        set cudnn_dir $cudnn_dirs[-1]
        set cudnn_version (basename $cudnn_dir | string replace -r 'cudnn-(.*)_cuda-.*' '$1')

        echo "选择最新 cuDNN 版本: $cudnn_version，路径: $cudnn_dir"
        if test -d "$cudnn_dir/lib"
            set --global --export LD_LIBRARY_PATH "$cudnn_dir/lib" $LD_LIBRARY_PATH
        else if test -d "$cudnn_dir/lib64"
            set --global --export LD_LIBRARY_PATH "$cudnn_dir/lib64" $LD_LIBRARY_PATH
        end
        set --global --export CPATH "$cudnn_dir/include" $CPATH
    end

    # 验证切换是否成功并记录日志
    set log_path "$HOME/.log/.cuda_switch.log"
    if type -q nvcc
        set current_version (nvcc --version | grep -oP 'release \K[0-9]+\.[0-9]+')
        echo "已切换到 CUDA 版本: $current_version"
        echo "$(date): Switched to CUDA $current_version" >> $log_path
    else
        echo "警告: nvcc 未找到，请检查 CUDA $target_version 是否正确安装！"
        echo "$(date): Failed to switch to CUDA $target_version (nvcc not found)" >> $log_path
        return 1
    end
end
