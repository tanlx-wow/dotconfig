-- ~/.config/nvim/lua/TLX/plugins/markview.lua
return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	config = function()
		local presets = require("markview.presets")

		require("markview").setup({
			preview = {
				icon_provider = "internal",
				makrdown = {
					headings = presets.headings.marker,
				},
			},
		})
	end,
}
