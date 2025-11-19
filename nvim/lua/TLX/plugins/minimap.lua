-- ~/.config/nvim/lua/TLX/plugins/minimap.lua
return {
	"wfxr/minimap.vim",
	lazy = false, -- load on startup
	init = function()
		-- Basic recommended settings
		vim.g.minimap_width = 2
		vim.g.minimap_auto_start = 0
		vim.g.minimap_auto_start_win_enter = 0
		vim.g.minimap_side = "right"
	end,
}
