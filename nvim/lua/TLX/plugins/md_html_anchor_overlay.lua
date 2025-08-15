-- lua/md_html_anchor_overlay.lua
local ns = vim.api.nvim_create_namespace("md_html_anchor_overlay")

local function render(buf)
	if vim.bo[buf].filetype ~= "markdown" then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i, line in ipairs(lines) do
		local s, e, name = line:find('<a%s+name="([^"]+)"></a>') -- or id="..."
		if s then
			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, {
				end_col = e,
				hl_group = "Conceal", -- hide raw HTML
				conceal = "",
				virt_text = { { "󰌹 " .. name, "RenderMarkdownLink" } }, -- your icon + highlight
				virt_text_pos = "overlay",
				priority = 120,
			})
		end
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
	pattern = "*.md",
	callback = function(a)
		render(a.buf)
	end,
})
