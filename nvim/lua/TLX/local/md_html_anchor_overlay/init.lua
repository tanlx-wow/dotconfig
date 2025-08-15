local M = {}
local ns = vim.api.nvim_create_namespace("md_html_anchor_overlay")

function M.setup(opts)
	opts = opts or {}
	local icon = opts.icon or "󰌹 "
	local hl = opts.highlight or "RenderMarkdownLink"
	local conceal = opts.conceal ~= false

	local function paint(buf)
		if vim.bo[buf].filetype ~= "markdown" then
			return
		end
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

		-- allow hiding the raw HTML
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		for i, line in ipairs(lines) do
			-- try name="…", then id="…" (support single or double quotes)
			local s, e, name = line:find("<a%s+name=['\"]([^'\"]+)['\"]></a>")
			if not s then
				s, e, name = line:find("<a%s+id=['\"]([^'\"]+)['\"]></a>")
			end
			if s and e and name and #name > 0 then
				local ext = {
					end_col = e,
					virt_text = { { icon .. name, hl } },
					virt_text_pos = "overlay",
					priority = 120,
				}
				if conceal then
					ext.hl_group = "Conceal"
					ext.conceal = ""
				end
				vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, ext)
			end
		end
	end

	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
		pattern = { "*.md", "*.markdown" },
		callback = function(a)
			paint(a.buf)
		end,
	})
end

return M
