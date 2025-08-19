return {
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- load before other UI plugins
		lazy = false,

		config = function()
			-- Configure Tokyonight with the "moon" style
			require("tokyonight").setup({
				style = "moon", -- <-- pick the "moon" variant
				transparent = false, -- set to true if you want transparent bg
			})

			-- Load the colorscheme
			vim.opt.termguicolors = true
			vim.cmd.colorscheme("tokyonight-moon")

			-- Floats look like normal windows
			vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
			vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })

			-- Optional: set your own terminal palette
			local ansi = {
				"#214969",
				"#E52E2E",
				"#44FFB1",
				"#FFE073",
				"#0FC5ED",
				"#a277ff",
				"#24EAF7",
				"#24EAF7",
			}
			local brights = {
				"#214969",
				"#E52E2E",
				"#44FFB1",
				"#FFE073",
				"#A277FF",
				"#a277ff",
				"#24EAF7",
				"#24EAF7",
			}
			for i = 0, 7 do
				vim.g["terminal_color_" .. i] = ansi[i + 1]
				vim.g["terminal_color_" .. (i + 8)] = brights[i + 1]
			end

			-- Terminal cursor highlight
			vim.api.nvim_set_hl(0, "TermCursor", { fg = "#011423", bg = "#47FF9C" })
			vim.api.nvim_set_hl(0, "TermCursorNC", { fg = "#011423", bg = "#47FF9C" })
		end,
	},
}
