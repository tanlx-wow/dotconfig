return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			cmdline = {
				enabled = true, -- enable the command-line UI
				view = "cmdline_popup", -- show in the middle
			},
			views = {
				notify = {
					replace = true,
					merge = true,
					timeout = 3000, -- 🕛 tim in ms (3000 = 3s)
				},
				cmdline_popup = {
					position = {
						row = "50%",
						col = "50%",
					},
					size = {
						width = 60,
						height = "auto",
					},
				},
			},
		})
	end,
}
