return {
	"petertriho/nvim-scrollbar",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("scrollbar").setup({
			show = true,
			show_in_active_only = false,
			set_highlights = true,
			handlers = {
				cursor = true,
				diagnostic = true, -- Shows your LSP errors/warnings on the scrollbar!
				gitsigns = false, -- Set to true if you use gitsigns plugin
				handle = true,
				search = true, -- Shows your search results on the scrollbar
				ale = false,
			},
		})
	end,
}
