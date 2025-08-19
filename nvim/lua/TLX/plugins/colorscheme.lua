return {
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- load before other UI plugins
		lazy = false,

		config = function()
			-- Configure Tokyonight with the "moon" style
			require("tokyonight").setup({
				style = "moon", -- <-- pick the "moon" variant
				transparent = true, -- set to true if you want transparent bg
			})

			-- Load the colorscheme
			vim.opt.termguicolors = true
			vim.cmd.colorscheme("tokyonight-moon")

			-- Floats look like normal windows
			vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
			vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
			-- Make NvimTree transparent
			vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })

			-- Optional: remove the background from the NvimTree end-of-buffer `~` chars
			vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

			-- Terminal cursor highlight
			-- vim.api.nvim_set_hl(0, "TermCursor", { fg = "#011423", bg = "#47FF9C" })
			-- vim.api.nvim_set_hl(0, "TermCursorNC", { fg = "#011423", bg = "#47FF9C" })
		end,
	},
}
