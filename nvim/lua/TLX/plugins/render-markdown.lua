return {
	-- 1) render-markdown.nvim
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = "markdown",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
		config = function()
			require("render-markdown").setup({
				link = {
					enabled = true,
					render_modes = false,
					footnote = { enabled = true, superscript = true, prefix = "", suffix = "" },
					image = "󰥶 ",
					email = "󰀓 ",
					hyperlink = "󰌹 ",
					highlight = "RenderMarkdownLink",
					wiki = {
						icon = "󱗖 ",
						body = function()
							return nil
						end,
						highlight = "RenderMarkdownWikiLink",
					},
					custom = {
						web = { pattern = "^http", icon = "󰖟 " },
						github = { pattern = "github%.com", icon = "󰊤 " },
						gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
						stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
						wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
						youtube = { pattern = "youtube%.com", icon = "󰗃 " },
					},
				},
				checkbox = {
					enabled = true,
					render_modes = false,
					bullet = false,
					right_pad = 1,
					unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
					checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
					custom = { todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" } },
				},
				bullet = {
					enabled = true,
					render_modes = false,
					icons = { "●", "○", "◆", "◇" },
					ordered_icons = function(ctx)
						local value = vim.trim(ctx.value)
						local index = tonumber(value:sub(1, #value - 1))
						return ("%d."):format(index > 1 and index or ctx.index)
					end,
					left_pad = 0,
					right_pad = 0,
					highlight = "RenderMarkdownBullet",
					scope_highlight = {},
				},
				quote = { icon = "▋" },
				anti_conceal = {
					enabled = true,
					ignore = { code_background = true, sign = true },
					above = 0,
					below = 0,
				},
				latex = {
					-- Turn on / off latex rendering.
					enabled = false,
					-- Additional modes to render latex.
					render_modes = false,
					-- Executable used to convert latex formula to rendered unicode.
					-- If a list is provided the first command available on the system is used.
					converter = "latex2text",
					-- Highlight for latex blocks.
					highlight = "RenderMarkdownMath",
					-- Determines where latex formula is rendered relative to block.
					-- | above  | above latex block                               |
					-- | below  | below latex block                               |
					-- | center | centered with latex block (must be single line) |
					position = "center",
					-- Number of empty lines above latex blocks.
					top_pad = 0,
					-- Number of empty lines below latex blocks.
					bottom_pad = 0,
				},
			})
		end,
	},

	-- 2) local helper to render `{#id}` anchors (without HTML)
	{
		name = "md-html-anchor-overlay",
		dir = vim.fn.stdpath("config") .. "/lua/TLX/local/md_html_anchor_overlay",
		ft = "markdown",
		dependencies = { "MeanderingProgrammer/render-markdown.nvim" },
		opts = {
			icon = "󰌹 ", -- "" to hide the overlay
			highlight = "RenderMarkdownLink",
			conceal = true, -- false to show raw {#id} text too
		},
		config = function(_, opts)
			require("TLX.local.md_html_anchor_overlay").setup(opts)
		end,
	},
}
