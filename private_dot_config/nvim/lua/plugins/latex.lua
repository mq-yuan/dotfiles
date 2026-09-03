return {
	"lervag/vimtex",
	lazy = false,
	ft = { "tex", "bib" },
	init = function()
		vim.g.vimtex_view_method = "general"
		vim.g.vimtex_compiler_method = "latexmk"
	end,
}
