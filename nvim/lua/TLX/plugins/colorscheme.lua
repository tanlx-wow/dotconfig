return {
	"folke/tokyonight.nvim",
	lazy = false, -- load immediately
	priority = 1000, -- make sure it loads before other UI stuff

	config = function()
		-- 1) Set the colorscheme
		vim.cmd([[colorscheme tokyonight-night]])

		-- 2) Enable true color
		vim.opt.termguicolors = true

		-- 3) Make floats look like normal windows (helps LazyGit, Telescope, etc.)
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
		vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
	end,
}
