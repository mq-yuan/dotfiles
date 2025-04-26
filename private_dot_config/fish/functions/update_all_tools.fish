# ~/.config/fish/functions/update_all_tools.fish
function update_all_tools
    # 定义日志文件路径
    if test -f $UPDATE_LOG_FILE -a (wc -c < $UPDATE_LOG_FILE) -gt 10485760 # 10MB
        mv $UPDATE_LOG_FILE $UPDATE_LOG_FILE.(date +%F).bak
    end

    # 日志辅助函数：包装命令并记录输出
    function log_command
        set -l cmd $argv[1]
        echo "Running: $cmd" >> $UPDATE_LOG_FILE
        fish -c "$cmd" 2>&1 | tee -a $UPDATE_LOG_FILE
    end

    # 定义打印头部的函数，带日志
    function print_header
        set -l header $argv
        echo ""
        echo "============================" | tee -a $UPDATE_LOG_FILE
        echo $header | tee -a $UPDATE_LOG_FILE
        echo "============================" | tee -a $UPDATE_LOG_FILE
    end

    # 在脚本开始时记录时间
    echo "=== Update started at "(date)" ===" >> $UPDATE_LOG_FILE

    function update_apt
        print_header "正在更新 apt 包"
        if type -q apt
            log_command "sudo apt update" 
            log_command "sudo apt upgrade -y" 
        else
            echo "未安装 apt，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_flatpak
        print_header "正在更新 Flatpak 应用"
        if type -q flatpak
            log_command "flatpak update -y" 
            log_command "flatpak uninstall --unused -y" 
        else
            echo "未安装 Flatpak，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_snap
        print_header "正在更新 Snap 应用"
        if type -q snap
            log_command "sudo snap refresh" 
        else
            echo "未安装 Snap，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_homebrew
        print_header "正在更新 Homebrew（注意：Ubuntu 中使用 Homebrew 可能与 apt 冲突）"
        if type -q brew
            log_command "brew update" 
            log_command "brew upgrade" 
        else
            echo "未安装 Homebrew，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_rust
        print_header "正在更新 Rustup"
        if type -q rustup
            log_command "rustup update" 
        else
            echo "未安装 Rustup，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_asdf
        print_header "正在更新 asdf 和插件"
        if type -q asdf
            log_command "asdf plugin update --all" 
        else
            echo "未安装 asdf，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_fisher
        print_header "正在更新 Fisher 插件"
        if type -q fisher
            log_command "fisher update" 
        else
            echo "未安装 Fisher，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    function update_conda
        print_header "正在更新 Conda 和所有包"
        if type -f $HOME/miniforge3/bin/conda
            log_command "conda update -n base conda -y" 
            log_command "conda update --all -y" 
        else
            echo "未安装 Conda，跳过更新。" | tee -a $UPDATE_LOG_FILE
        end
    end

    # 定义工具列表和状态
    set -l os (uname)
    if test $os = "Darwin"
        set tools "Homebrew (brew)" "Rust 和 Cargo (rustup, cargo)" "asdf 和插件" "Fisher 插件" "Conda 和包"
        set tool_selected 0 0 0 0 0 
    else if test $os = "Linux"
        set tools "apt" "Flatpak" "Snap" "Homebrew (brew)" "Rust 和 Cargo (rustup, cargo)" "asdf 和插件" "Fisher 插件" "Conda 和包"
        set tool_selected 0 0 0 0 0 0 0 0 
    end

    function show_menu --no-scope-shadowing
        clear
        echo "命令行工具更新脚本"
        echo "========================================"
        echo "选择要更新的工具："
        echo ""

        for i in (seq (count $tools))
            set -l item_status "[ ]"
            if test $tool_selected[$i] -eq 1
                set item_status "[X]"
            end
            echo "$i) $item_status $tools[$i]"
        end

        echo ""
        echo "a) 全选"
        echo "c) 清除所有选择"
        echo "r) 运行更新"
        echo "q) 退出"
        echo ""
        echo -n "请输入选项: "
    end

    # 主程序循环
    while true
        show_menu
        read -l choice

        switch $choice
            case q
                echo "退出脚本" | tee -a $UPDATE_LOG_FILE
                echo "=== Update finished at "(date)" ===" >> $UPDATE_LOG_FILE
                return 0
            case a
                # 全选
                for i in (seq (count $tools))
                    set tool_selected[$i] 1
                end
            case c
                # 清除所有选择
                for i in (seq (count $tools))
                    set tool_selected[$i] 0
                end
            case r
                # 运行更新
                set -l has_selection 0
                for i in (seq (count $tools))
                    if test $tool_selected[$i] -eq 1
                        set has_selection 1
                        if test $os = "Darwin"
                            switch $i
                                case 1
                                    update_homebrew
                                case 2
                                    update_rust
                                case 3
                                    update_asdf
                                case 4
                                    update_fisher
                                case 5
                                    update_conda
                            end
                        else if test $os = "Linux"
                            switch $i
                                case 1
                                    update_apt
                                case 2
                                    update_flatpak
                                case 3
                                    update_snap
                                case 4
                                    update_homebrew
                                case 5
                                    update_rust
                                case 6
                                    update_asdf
                                case 7
                                    update_fisher
                                case 8
                                    update_conda
                            end
                        end
                    end
                end

                if test $has_selection -eq 0
                    echo "没有选择任何工具，请先选择要更新的工具。" | tee -a $UPDATE_LOG_FILE
                    sleep 2
                else
                    echo "" | tee -a $UPDATE_LOG_FILE
                    print_header "所有更新已完成！"
                    echo "按回车键返回菜单..." | tee -a $UPDATE_LOG_FILE
                    read
                end
            case '*'
                # 检查是否为数字
                if string match -rq '^[0-9]+$' -- $choice
                    set -l idx (math $choice)
                    if test $idx -ge 1 -a $idx -le (count $tools)
                        # 切换选中状态
                        if test $tool_selected[$idx] -eq 0
                            set tool_selected[$idx] 1
                        else
                            set tool_selected[$idx] 0
                        end
                    else
                        echo "无效选项，请输入 1-"(count $tools)" 之间的数字。" | tee -a $UPDATE_LOG_FILE
                        sleep 1
                    end
                else
                    echo "无效选项，请重试。" | tee -a $UPDATE_LOG_FILE
                    sleep 1
                end
        end
    end
end
