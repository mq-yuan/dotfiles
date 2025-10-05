# Mq-Yuan 的 Dotfiles

<div align="center">

[![由 chezmoi 管理](https://img.shields.io/badge/managed%20by-chezmoi-brightgreen?style=for-the-badge&logo=chezmoi)](https://www.chezmoi.io/)
[![基于 AstroNvim](https://img.shields.io/badge/Neovim-AstroNvim-57A143?style=for-the-badge&logo=neovim)](https://astronvim.com/)
[![Shell: Fish](https://img.shields.io/badge/shell-Fish-blue?style=for-the-badge&logo=fish)](https://fishshell.com/)
[![许可证: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

一套精心调校的、跨平台 (Linux & macOS) 的开发环境，通过 `chezmoi` 进行高效管理。

</div>

---

## 🌟 设计哲学

这个仓库不仅仅是配置文件的集合，它更是一套系统化的方法论，旨在任何机器上构建一个一致、强大且安全的开发环境。其核心原则如下：

*   **自动化 (Automation)**: 充分利用 `chezmoi` 和脚本来自动化环境的安装与配置。
*   **安全性 (Security)**: 仓库中**绝不**存储任何敏感信息。所有秘密（如 API 密钥）都通过 `chezmoi` 与 `KeepassXC` 的集成进行安全管理。
*   **一致性 (Consistency)**: 在不同的操作系统（Linux 和 macOS）上提供统一、无缝的体验。
*   **生产力 (Productivity)**: 一个高度定制的 Neovim 和 Fish shell 环境，并由 AI 工具强力驱动，为实现最高效率而设计。

## ✨ 功能亮点

### 🖥️ Shell & 终端环境

整个环境的基础构建在一系列强大而现代的终端工具之上。

*   **[Fish Shell](https://fishshell.com/)**: 一个智能且用户友好的命令行 Shell。
    *   **模块化配置**: 通过 `conf.d` 目录结构实现清晰、有组织的配置管理。
    *   **插件管理**: 使用 `fisher` 管理插件生态。
    *   **智能补全与缩写**: 为常用命令和 Git 工作流设置了丰富的缩写，大幅提升效率。
*   **[Tmuxinator](https://github.com/tmuxinator/tmuxinator)**: 轻松创建和管理 `tmux` 会话。预设了如 `dashboard` (`btop` + `nvtop`) 等会话，提供即时系统监控视图。
*   **[Fastfetch](https://github.com/fastfetch-cli/fastfetch)**: 高度定制化且美观的系统信息展示工具。
*   **[Rofi](https://github.com/davatorium/rofi)**: 一个功能强大、主题丰富的应用启动器和窗口切换器。

### 🚀 Neovim: 一个现代化的 IDE

Neovim 配置基于优秀的 [AstroNvim](https://astronvim.com/) 框架，并将其扩展为一个功能完备的集成开发环境。

*   **AI 驱动开发**:
    *   **`aichat.nvim`**: 集成了由 `aichat` 驱动的聊天界面，允许在编辑器内直接与多个大语言模型（LLM）进行交互。
    *   **代码生成与补全**: 通过 AI 增强了代码生成和自动补全的能力。
*   **丰富的语言支持**: 通过 LSP 为多种语言提供开箱即用的支持，包括 `basedpyright` (Python), `clangd` (C/C++), `rust-analyzer` (Rust) 和 `tinymist` (Typst) 等。
*   **深度集成工具**:
    *   **[LazyGit](https://github.com/jesseduffield/lazygit)**: 只需一次按键即可访问的 `git` 终端 UI。
    *   **[Yazi](https://github.com/sxyazi/yazi)**: 一款速度极快、支持图片预览的终端文件管理器。
    *   **[Aerial](https://github.com/stevearc/aerial.nvim)**: 一个用于快速导航代码结构的代码大纲窗口。
*   **精美的用户界面**: 使用了定制版的 `catppuccin` 主题和 `nvim-web-devicons` 图标，界面精美。

### 🌐 动态网络与代理配置

网络层由 [Clash Verge](https://github.com/clash-verge-rev/clash-verge-rev) 管理，其配置方式尤为强大和动态。

*   **零接触配置**: 整套 `clash-verge` 配置文件由一个 JavaScript 模板 (`.chezmoitemplates/clash-verge-script.js`) 以编程方式动态生成。
*   **动态节点分组**: 根据代理节点的名称（如 HK, US, SG）自动创建 `url-test`, `load-balance` 和 `select` 分组。
*   **高级路由规则**: 集成了来自 `sukkaw` 和 `YYDS` 的规则集，能够智能分流广告、流媒体、AI 服务以及国内外网站的流量。
*   **DNS 优化**: 采用 Fake-IP 模式，并为国内外域名指定不同的 DNS 服务器，以提升解析速度和可靠性。

### 🔒 安全的秘密管理

安全性是重中之重。所有敏感信息都由 `chezmoi` 处理，绝不会存储在此仓库中。

*   **工具**: `chezmoi` + `KeepassXC`。
*   **工作流**: 在执行 `chezmoi apply` 时，`chezmoi` 会从 `KeepassXC` 数据库中安全地获取秘密（API 密钥、令牌等），并实时填充到模板文件 (`.tmpl`) 中。

---

## 🚀 快速开始

### 前置条件

1.  **[chezmoi](https://www.chezmoi.io/install/)**: 点阵文件管理器。
2.  **[KeepassXC](https://keepassxc.org/)**: 用于管理秘密。
3.  **[Fish Shell](https://fishshell.com/)**: 主要的交互式 Shell。
4.  **[Nerd Font](https://www.nerdfonts.com/)**: Neovim 和其他终端工具中图标正常显示所必需。

### 安装步骤

1.  **初始化 `chezmoi`**:
    ```bash
    chezmoi init --apply https://github.com/mq-yuan/dotfiles
    ```
    此命令将克隆本仓库，并将配置应用到您的家目录。

2.  **安装 Fish 插件**:
    启动 `fish`，插件将自动安装。您也可以手动运行 `fisher install` 来安装。

3.  **安装 Neovim 插件**:
    启动 `nvim`。 [Lazy.nvim](https://github.com/folke/lazy.nvim) 将自动同步插件。您也可以随时运行 `:Lazy sync` 来确保所有插件都已更新。

现在，请尽情享受您全新的、高效的开发环境！