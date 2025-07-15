# Mq-Yuan 的 Dotfiles

[![chezmoi](https://img.shields.io/badge/managed%20by-chezmoi-brightgreen)](https://www.chezmoi.io/) [![Neovim](https://img.shields.io/badge/Neovim-AstroNvim-57A143?logo=neovim)](https://astronvim.com/)

这里是我的个人配置文件仓库，使用 [chezmoi](https://www.chezmoi.io/) 进行管理。主要包含了我的 Neovim, clash-verge, aichat 等工具的配置。

## ✨ 总览

这个仓库的核心是我的开发环境配置，主要包含：

* **Neovim 配置**: 基于 [AstroNvim v5](https://astronvim.com/) 框架，并集成了大量插件以优化开发体验，例如：
    * LSP: `basedpyright`, `clangd`, `rust-analyzer`, `tinymist` 等
    * AI 编程助手: `llm.nvim`，集成了 `gemini`, `grok`, `deepseek` 等多种模型
    * UI & 主题: 使用 `catppuccin` 主题的变体，来自[tribhuwan-kumar](https://github.com/catppuccin/nvim/discussions/323#discussioncomment-5287724)
    * 工具: `lazygit`, `yazi` 文件管理器, `aerial` 代码大纲等
* **Clash Verge 配置**: 通过 `chezmoi` 模板和 JavaScript 脚本 (`clash-verge-script.js`) 动态生成复杂的代理规则和节点组。
    * **动态节点分组**: 自动根据节点名称中的地区关键词（如 HK, TW, SG, US 等）创建 `url-test`, `load-balance` 和 `select` 分组。
    * **精细化分流规则**: 集成了来自 `sukkaw` 和 `YYDS` 的多种规则集，对广告、流媒体、AI 服务、国内外流量等进行精细化控制。
    * **DNS 优化**: 配置了 Fake-IP 模式并为国内外域名指定不同的 DNS 服务器，以提升访问速度和准确性。
* **AI Chat 配置**: 为 `aichat` 工具配置了多个 AI 模型提供商，包括 `xai`, `openai`, `gemini`, `deepseek` 等。
* **秘密管理**: 所有敏感信息（如 API Keys, Tokens, 服务器地址等）都通过 `chezmoi` 与 `keepassxc` 集成进行管理，确保了安全性。

## 🚀 安装与使用

**先决条件**:
1.  安装 [chezmoi](https://www.chezmoi.io/install/)。
2.  安装 [KeepassXC](https://keepassxc.org/) 并设置好你的数据库，确保 `chezmoi` 可以访问它。
3.  安装 [Nerd Font](https://www.nerdfonts.com/) 字体以确保 Neovim 中的图标正常显示。

**安装步骤**:

使用 `chezmoi` 初始化并应用配置：

```bash
chezmoi init --apply [https://github.com/mq-yuan/dotfiles](https://github.com/mq-yuan/dotfiles)
