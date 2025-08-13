return {
	"code-biscuits/nvim-biscuits",
	event = "VeryLazy",
	config = function()
		require("nvim-biscuits").setup({
			show_on_start = false, -- don't draw on buffer load
			cursor_line_only = true, -- only show on the line with the cursor
			prefix_string = " 🫷📎 ",
			-- optional tuning:
			-- default_config = { max_length = 80, min_distance = 5 },
		})
	end,
}
