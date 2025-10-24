-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	config = function()
		local presets = require("markview.presets")

		require("markview").setup({
			preview = {
				icon_provider = "internal",
			},
			markdown = {
				headings = presets.headings.slanted, -- classic preset shown in README
				code = presets.code.block, -- renders fenced code blocks cleanly
				blockquotes = presets.blockquotes.box, -- subtle box style
				checkbox = presets.checkbox.default, -- renders checkboxes like [x]
				list_items = presets.list_items.default, -- bullet and numbering style
				links = presets.links.underline, -- underlined links
			},
		})
	end,

	-- For blink.cmp's completion
	-- source
	-- dependencies = {
	--     "saghen/blink.cmp"
	-- },
}
