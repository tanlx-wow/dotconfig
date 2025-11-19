-- ~/.config/nvim/lua/TLX/plugins/minimap.lua
return {
	"wfxr/minimap.vim",
	lazy = false, -- load on startup
	init = function()
		-- Basic recommended settings
		vim.g.minimap_width = 10
		vim.g.minimap_auto_start = 0
		vim.g.minimap_auto_start_win_enter = 0
		vim.g.minimap_side = "right"
		vim.g.minimap_base_highlight = "Normal"
		vim.g.minimap_block_filetypes = { "fugitive", "nerdtree", "tagbar" }
		vim.g.minimap_close_filetypes = { "startify", "netrw", "vim-plug" }
		vim.g.minimap_git_colors = 1
		vim.g.minimap_highlight_range = 1
	end,
}
