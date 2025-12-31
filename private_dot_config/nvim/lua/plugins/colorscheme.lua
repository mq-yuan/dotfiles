
return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
        vim.api.nvim_command("colorscheme catppuccin")
    end,
}
