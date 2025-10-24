-- ~/.config/nvim/lua/TLX/plugins/markview.lua
return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	config = function()
		local ok_presets, presets = pcall(require, "markview.presets")
		if not ok_presets then
			vim.notify("markview.presets not found", vim.log.levels.WARN)
			return
		end

		-- Handle naming differences across versions:
		local H = presets.headings
		local BQ = presets.block_quotes or presets.blockquotes
		local CB = presets.checkboxes or presets.checkbox
		local HL = presets.hyperlinks or presets.links
		local LI = presets.list_items
		local TB = presets.tables
		local CBLOCK = presets.code_blocks -- may or may not exist; optional

		require("markview").setup({
			preview = {
				enable = true,
				icon_provider = "internal", -- "mini" or "devicons" also ok
				filetypes = { "md", "rmd", "quarto" },
			},

			-- HTML/Latex/Typst/YAML can stay defaults; focus on markdown bits:
			markdown = {
				enable = true,
				headings = H and H.glow or nil, -- headings preset
				block_quotes = BQ and BQ.box or nil, -- boxed blockquotes
				list_items = LI and LI.default or nil, -- bullets/numbers
				tables = TB and TB.default or nil, -- table styling
				code_blocks = CBLOCK and CBLOCK.plain or nil, -- OPTIONAL preset
			},
			markdown_inline = {
				enable = true,
				checkboxes = CB and CB.default or nil, -- [ ] / [x]
				hyperlinks = HL and HL.underline or nil, -- underlined links
				inline_codes = presets.inline_codes and presets.inline_codes.plain or nil, -- OPTIONAL
			},
		})
	end,
}
