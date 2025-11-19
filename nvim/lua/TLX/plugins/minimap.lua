-- ~/.config/nvim/lua/TLX/plugins/minimap.lua
return {
	"wfxr/minimap.vim",
	lazy = false, -- load on startup
	config = function()
		-- Basic recommended settings
		vim.g.minimap_width = 10
		vim.g.minimap_auto_start = 0
		vim.g.minimap_auto_start_win_enter = 1
	end,
}
