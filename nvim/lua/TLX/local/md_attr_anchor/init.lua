-- local/md_attr_anchor/init.lua
-- Render `{#id}` anchors in Markdown: hide the text and show an icon + name.
local M = {}
local ns = vim.api.nvim_create_namespace("md_attr_anchor")

---@param opts { icon?: string, highlight?: string, conceal?: boolean }
function M.setup(opts)
	opts = opts or {}
	local icon = opts.icon or "󰌹 "
	local hl = opts.highlight or "RenderMarkdownLink"
	local do_conceal = opts.conceal ~= false -- default true

	local function paint(buf)
		if vim.bo[buf].filetype ~= "markdown" then
			return
		end
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

		-- helpful for hiding the raw text
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		for i, line in ipairs(lines) do
			-- Skip obvious code fences/indented code lines
			if not line:match("^%s*```") and not line:match("^%s*~~~") and not line:match("^%s*%t") then
				-- find all {#id} occurrences on the line
				local start = 1
				while true do
					local s, e, id = line:find("{#([%w%._%-%:]+)}", start)
					if not s then
						break
					end
					local ext = {
						end_col = e,
						virt_text = { { icon .. id, hl } },
						virt_text_pos = "overlay",
						priority = 120,
					}
					if do_conceal then
						ext.hl_group = "Conceal"
						ext.conceal = ""
					end
					vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, ext)
					start = e + 1
				end
			end
		end
	end

	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
		pattern = "*.md",
		callback = function(a)
			paint(a.buf)
		end,
	})

	-- Optional: make `gx` on the overlay jump to that anchor elsewhere
	vim.keymap.set("n", "gx", function()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		row = row - 1
		local marks = vim.api.nvim_buf_get_extmarks(0, ns, { row, 0 }, { row, -1 }, { details = true })
		for _, m in ipairs(marks) do
			local d = m[4]
			if col >= d.col and col < d.end_col then
				local text = d.virt_text and d.virt_text[1] and d.virt_text[1][1] or ""
				local id = text:match("%s(.+)$")
				if id then
					-- Jump to next anchor with the same id (useful when scanning a big doc)
					vim.fn.search("{#" .. vim.pesc(id) .. "}", "w")
					return
				end
			end
		end
		vim.cmd("normal! gx")
	end, { desc = "Open link / jump to {#id} anchor" })
end

return M
