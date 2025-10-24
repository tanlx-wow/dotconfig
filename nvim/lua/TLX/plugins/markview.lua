-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	config = function()
		local presets = require("markview.presets")

		require("markview").setup({
			preview = {
				icon_provider = "devicons",
			},
			markdown = {
				headings = presets.headings.glow, -- classic preset shown in README
			},
		})
	end,

	-- For blink.cmp's completion
	-- source
	-- dependencies = {
	--     "saghen/blink.cmp"
	-- },
}
