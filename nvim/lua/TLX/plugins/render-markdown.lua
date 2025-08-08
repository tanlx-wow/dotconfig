return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.nvim", -- or another icon set
	},
	config = function()
		require("render-markdown").setup({
			link = {
				-- Turn on / off inline link icon rendering.
				enabled = true,
				-- Additional modes to render links.
				render_modes = false,
				-- How to handle footnote links, start with a '^'.
				footnote = {
					-- Turn on / off footnote rendering.
					enabled = true,
					-- Replace value with superscript equivalent.
					superscript = true,
					-- Added before link content.
					prefix = "",
					-- Added after link content.
					suffix = "",
				},
				-- Inlined with 'image' elements.
				image = "󰥶 ",
				-- Inlined with 'email_autolink' elements.
				email = "󰀓 ",
				-- Fallback icon for 'inline_link' and 'uri_autolink' elements.
				hyperlink = "󰌹 ",
				-- Applies to the inlined icon as a fallback.
				highlight = "RenderMarkdownLink",
				-- Applies to WikiLink elements.
				wiki = {
					icon = "󱗖 ",
					body = function()
						return nil
					end,
					highlight = "RenderMarkdownWikiLink",
				},
				-- Define custom destination patterns so icons can quickly inform you of what a link
				-- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
				-- patterns match a link the one with the longer pattern is used.
				-- The key is for healthcheck and to allow users to change its values, value type below.
				-- | pattern   | matched against the destination text                            |
				-- | icon      | gets inlined before the link text                               |
				-- | kind      | optional determines how pattern is checked                      |
				-- |           | pattern | @see :h lua-patterns, is the default if not set       |
				-- |           | suffix  | @see :h vim.endswith()                                |
				-- | priority  | optional used when multiple match, uses pattern length if empty |
				-- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
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
				unchecked = {
					icon = "󰄱 ",
					highlight = "RenderMarkdownUnchecked",
					scope_highlight = nil,
				},
				checked = {
					icon = "󰱒 ",
					highlight = "RenderMarkdownChecked",
					scope_highlight = nil,
				},
				custom = {
					todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
				},
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
				-- Which elements to always show, ignoring anti conceal behavior. Values can either be
				-- booleans to fix the behavior or string lists representing modes where anti conceal
				-- behavior will be ignored. Valid values are:
				--   head_icon, head_background, head_border, code_language, code_background, code_border,
				--   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
				ignore = {
					code_background = true,
					sign = true,
				},
				above = 0,
				below = 0,
			},
		}) -- your config here
	end,
}
