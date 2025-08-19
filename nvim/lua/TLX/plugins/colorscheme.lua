return {
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			local transparent = true
			-- local bg = "#011628"
			-- local bg_dark = "#011423"
			-- local bg_highlight = "#143652"
			-- local bg_search = "#0A64AC"
			-- local bg_visual = "#275378"
			-- local fg = "#CBE0F0"
			-- local fg_dark = "#B4D0E9"
			-- local fg_gutter = "#627E97"
			-- local border = "#547998"
			--
			require("tokyonight").setup({
				style = "night",
				transparent = transparent,
				styles = {
					sidebars = transparent and "transparent" or "dark",
					floats = transparent and "transparent" or "dark",
				},
				on_colors = function(colors)
					colors.bg = bg
					colors.bg_dark = transparent and colors.none or bg_dark
					colors.bg_float = transparent and colors.none or bg_dark
					colors.bg_highlight = bg_highlight
					colors.bg_popup = bg_dark
					colors.bg_search = bg_search
					colors.bg_sidebar = transparent and colors.none or bg_dark
					colors.bg_statusline = transparent and colors.none or bg_dark
					colors.bg_visual = bg_visual
					colors.border = border
					colors.fg = fg
					colors.fg_dark = fg_dark
					colors.fg_float = fg
					colors.fg_gutter = fg_gutter
					colors.fg_sidebar = fg_dark
				end,
			})
			-- load the colorscheme here
			vim.cmd([[colorscheme tokyonight]])
			-- 1) Truecolor on
			vim.opt.termguicolors = true

			-- 2) Make floats look like normal windows (helps LazyGit)
			vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
			vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })

			-- 3) Copy your WezTerm ANSI/brights into Neovim's terminal palette
			-- WezTerm colors you shared:
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

			-- 4) Optional: match terminal cursor colors (used by :terminal / LazyGit)
			vim.api.nvim_set_hl(0, "TermCursor", { fg = "#011423", bg = "#47FF9C" })
			vim.api.nvim_set_hl(0, "TermCursorNC", { fg = "#011423", bg = "#47FF9C" })
		end,
	},
}
