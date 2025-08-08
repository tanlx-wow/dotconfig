return {
	"code-biscuits/nvim-biscuits",
	event = "VeryLazy",
	config = function()
		require("nvim-biscuits").setup({
			toggle_keybind = "<leader>cb",
			show_on_start = false, -- defaults to false
			prefix_string = " 📎 ",
		})
	end,
}
