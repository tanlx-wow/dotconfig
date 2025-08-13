return {
	"code-biscuits/nvim-biscuits",
	event = "VeryLazy",
	config = function()
		require("nvim-biscuits").setup({
			toggle_keybind = "<leader>cb",
			show_on_start = false, -- don't show immediately
			prefix_string = " 🫷📎",
		})

		-- Only show biscuits when the cursor stays on a line for a moment
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				-- force refresh biscuits for the current line
				require("nvim-biscuits").refresh_biscuits()
			end,
		})
	end,
}
