return {
	"petertriho/nvim-scrollbar",
	-- v2 moves to main on 2026-11-16; remove this branch after updating then.
	branch = "refactor/v2",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"kevinhwang91/nvim-hlslens",
	},
	config = function()
		-- hlslens displays match counts; v2 collects scrollbar search marks natively.
		require("hlslens").setup({})

		require("scrollbar").setup({
			set_highlights = true,
			providers = {
				cursor = true,
				diagnostic = true,
				gitsigns = false,
				search = true,
				marks = false,
				ale = false,
			},
			scrollbar = {
				show = true,
				visibility = "all",
			},
		})

		-- Keep the search keymaps that trigger hlslens.
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
