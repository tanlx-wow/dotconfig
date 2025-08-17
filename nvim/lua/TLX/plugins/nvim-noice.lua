-- return {
-- 	"folke/noice.nvim",
-- 	event = "VeryLazy",
-- 	dependencies = {
-- 		"MunifTanjim/nui.nvim",
-- 		"rcarriga/nvim-notify",
-- 	},
-- 	config = function()
-- 		require("noice").setup({
-- 			cmdline = {
-- 				enabled = true, -- enable the command-line UI
-- 				view = "cmdline_popup", -- show in the middle
-- 			},
-- 			views = {
-- 				cmdline_popup = {
-- 					border = {
-- 						style = "rounded",
-- 						text = {
-- 							top = "🖥️command",
-- 							top_align = "center",
-- 						},
-- 					},
-- 					position = {
-- 						row = "50%",
-- 						col = "50%",
-- 					},
-- 					size = {
-- 						width = 60,
-- 						height = "auto",
-- 					},
-- 				},
-- 			},
-- 		})
-- 	end,
-- }
return {
	"folke/noice.nvim",
	opts = function(_, opts)
		opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
			enabled = true,
			view = "cmdline_popup",
		})
		opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
			cmdline_popup = {
				border = {
					style = "rounded",
					text = { top = " 💻 command ", top_align = "center" },
				},
				position = { row = "50%", col = "50%" },
				size = { width = 60, height = "auto" },
			},
		})
	end,
	dependencies = { "MunifTanjim/nui.nvim" },
}
