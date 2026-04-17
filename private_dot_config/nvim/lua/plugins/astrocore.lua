-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>cr"] = {
          function()
            local path = vim.fn.expand "%:."
            vim.fn.setreg("+", path)
            vim.notify("Copied relative path: " .. path)
          end,
          desc = "Copy relative file path",
        },
        ["<Leader>ca"] = {
          function()
            local path = vim.fn.expand "%:p"
            vim.fn.setreg("+", path)
            vim.notify("Copied absolute path: " .. path)
          end,
          desc = "Copy absolute file path",
        },
        ["<Leader>cn"] = {
          function()
            local name = vim.fn.expand "%:t"
            vim.fn.setreg("+", name)
            vim.notify("Copied file name: " .. name)
          end,
          desc = "Copy file name",
        },
      },
    },
  },
}
