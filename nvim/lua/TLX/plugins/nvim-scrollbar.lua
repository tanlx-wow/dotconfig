-- return {
-- 	"petertriho/nvim-scrollbar",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	config = function()
-- 		require("scrollbar").setup({
-- 			show = true,
-- 			show_in_active_only = false,
-- 			set_highlights = true,
-- 			handlers = {
-- 				cursor = true,
-- 				diagnostic = true, -- Shows your LSP errors/warnings on the scrollbar!
-- 				gitsigns = false, -- Set to true if you use gitsigns plugin
-- 				handle = true,
-- 				search = true, -- Shows your search results on the scrollbar
-- 				ale = false,
-- 			},
-- 		})
-- 	end,
-- }

return {
	"petertriho/nvim-scrollbar",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"kevinhwang91/nvim-hlslens",
	},
	config = function()
		-- 1. Initialize hlslens
		require("hlslens").setup({
			build_position_cb = function(plist, _, _, _)
				-- This ensures the scrollbar updates immediately when searching
				require("scrollbar.handlers.search").handler.show(plist.start_pos)
			end,
		})

		-- 2. Initialize your scrollbar
		require("scrollbar").setup({
			show = true,
			show_in_active_only = false,
			set_highlights = true,
			handlers = {
				cursor = true,
				diagnostic = true,
				gitsigns = false,
				handle = true,
				search = true,
				ale = false,
			},
		})

		-- 3. CRITICAL: Hook the scrollbar up to hlslens
		require("scrollbar.handlers.search").setup()

		-- 4. Set up the keymaps to trigger the lens and scrollbar marks
		local kopts = { noremap = true, silent = true }

		vim.api.nvim_set_keymap(
			"n",
			"n",
			[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
			kopts
		)
		vim.api.nvim_set_keymap(
			"n",
			"N",
			[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
			kopts
		)
		vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

		-- Clear search highlights and lens easily
		vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)
	end,
}
