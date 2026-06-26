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
*   **[Tmuxinator](https://github.com/tmuxinator/tmuxinator)**: 轻松创建和管理 `tmux` 会话。预设的 `dashboard` (`btop` + `nvtop` / `gdu-go` + `duf`) 通过 `.chezmoiignore` 限定在 Linux 主机分发。
*   **[Fastfetch](https://github.com/fastfetch-cli/fastfetch)**: 高度定制化且美观的系统信息展示工具，仅在标记 `personal` 的主机上分发。

### 🚀 Neovim: 一个现代化的 IDE

Neovim 配置基于优秀的 [AstroNvim](https://astronvim.com/) 框架，并将其扩展为一个功能完备的集成开发环境。

*   **丰富的语言支持**: 通过 LSP 为多种语言提供开箱即用的支持，包括 `basedpyright` (Python), `clangd` (C/C++), `rust-analyzer` (Rust) 和 `tinymist` (Typst) 等。LSP/formatter/debugger 由 `mason-tool-installer` 自动安装，列表见 `private_dot_config/nvim/lua/plugins/mason.lua`。
*   **深度集成工具**:
    *   **[LazyGit](https://github.com/jesseduffield/lazygit)**: 只需一次按键即可访问的 `git` 终端 UI。
    *   **[Yazi](https://github.com/sxyazi/yazi)**: 一款速度极快、支持图片预览的终端文件管理器。
    *   **[Aerial](https://github.com/stevearc/aerial.nvim)**: 一个用于快速导航代码结构的代码大纲窗口。
*   **精美的用户界面**: 使用了定制版的 `catppuccin` 主题和 `nvim-web-devicons` 图标，界面精美。

### 🌐 动态网络与代理配置

网络层使用 [Mihomo](https://github.com/MetaCubeX/mihomo) 作为内核，由 [Mihomo Party (Sparkle)](https://github.com/mihomo-party-org/mihomo-party) 提供 GUI。节点与密钥通过 `chezmoi` 模板从 KeepassXC 注入，仓库本身不包含明文凭据；运行时改写脚本（节点分组 / 规则 / DNS）则交由 Sparkle 自带的同步功能托管。

*   **零接触配置**: Sparkle 的 `Profiles.yaml` 是 chezmoi stub，引用 `.chezmoitemplates/clash-verge-profile.yaml`（节点）。订阅 token、Hysteria2/TUIC/VLESS 端口、Webdav 密码等敏感字段全部来自 KeepassXC 的 `Applications/clash-verge` 条目。
*   **运行时改写脚本**: 节点分组、路由规则与 DNS 改写由 Sparkle 的 override 脚本（`Script.js`）完成。**该脚本不再纳入 chezmoi 管理**，改用 Sparkle 自带的同步功能跨机分发 —— Sparkle 运行时不会回写 chezmoi 渲染的版本，二者长期漂移、维护成本高，故移交 Sparkle 托管。
*   **动态节点分组**: 脚本根据节点名（HK / US / SG / JP …）自动生成 `url-test`、`load-balance`、`select` 三类分组。
*   **高级路由规则**: 集成 `sukkaw` 与 `YYDS` 规则集，分流广告、流媒体、AI 服务以及国内外站点。
*   **DNS 优化**: Fake-IP 模式，国内外域名走不同的上游 DNS，兼顾解析速度和可达性。
*   **历史注记**: `.chezmoitemplates/clash-verge-profile.yaml` 的命名沿用早期使用 Clash Verge 时的名字 —— 切到 Mihomo Party 后内容仍然兼容，因此保留了文件名以减少 diff 噪音。

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
    启动 `nvim`。 [Lazy.nvim](https://github.com/folke/lazy.nvim) 将自动同步插件。也可以随时运行 `:Lazy sync` 来更新所有插件。注意：`lazy-lock.json` **未**纳入 chezmoi 管理，每台主机自行维护本机的版本快照；需要回滚到已知好的状态时使用 `:Lazy restore`。

现在，请尽情享受您全新的、高效的开发环境！