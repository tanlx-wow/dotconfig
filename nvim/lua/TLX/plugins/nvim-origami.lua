return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
	config = function()
		require("origami").setup({
			useLspFoldsWithTreesitterFallback = true, -- required for `autoFold`
			pauseFoldsOnSearch = true,
			foldtext = {
				enabled = true,
				padding = 3,
				lineCount = {
					template = "%d lines", -- `%d` is replaced with the number of folded lines
					hlgroup = "Comment",
				},
				diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
				gitsignsCount = true, -- requires `gitsigns.nvim`
			},
			autoFold = {
				enabled = true,
				kinds = { "Comment" }, ---@type lsp.FoldingRangeKind[]
			},
			foldKeymaps = {
				setup = false, -- modifies `h` and `l`
				hOnlyOpensOnFirstColumn = false,
			},
		})
	end,
}
