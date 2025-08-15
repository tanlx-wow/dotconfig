-- ~/.config/nvim/lua/local/md_html_anchor_overlay/init.lua
local M = {}
local ns = vim.api.nvim_create_namespace("md_html_anchor_overlay")

local function paint(buf, opts)
	if vim.bo[buf].filetype ~= "markdown" then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local icon = opts.icon or "󰌹 "
	local hl = opts.highlight or "RenderMarkdownLink"
	local conceal = opts.conceal ~= false

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i, line in ipairs(lines) do
		-- support name="..." OR id="..." (single or double quotes)
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

local function clear(buf)
	vim.api.nvim_buf_clear_namespace(buf or 0, ns, 0, -1)
end

function M.setup(opts)
	opts = opts or {}

	local group = vim.api.nvim_create_augroup("MdHtmlAnchorOverlay", { clear = true })

	-- On enter/show/change: paint (only when NOT in insert)
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged" }, {
		group = group,
		pattern = { "*.md", "*.markdown" },
		callback = function(a)
			if not vim.fn.mode():match("i") then
				paint(a.buf, opts)
			end
		end,
	})

	-- While typing (TextChangedI) we don't repaint; avoid flicker.

	-- Insert mode: show raw text (remove overlays & disable conceal)
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		pattern = { "*.md", "*.markdown" },
		callback = function()
			if vim.bo.filetype == "markdown" then
				clear(0)
				vim.b._anchor_prev_conceal = vim.b._anchor_prev_conceal or vim.opt_local.conceallevel:get()
				vim.opt_local.conceallevel = 0
			end
		end,
	})

	-- Leave insert: restore conceal & re-paint overlays
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		pattern = { "*.md", "*.markdown" },
		callback = function()
			if vim.bo.filetype == "markdown" then
				vim.opt_local.conceallevel = vim.b._anchor_prev_conceal or 2
				paint(0, opts)
			end
		end,
	})

	-- Optional: when leaving buffer, restore original conceallevel
	vim.api.nvim_create_autocmd("BufLeave", {
		group = group,
		pattern = { "*.md", "*.markdown" },
		callback = function(a)
			if vim.b[a.buf]._anchor_prev_conceal ~= nil then
				vim.opt_local.conceallevel = vim.b[a.buf]._anchor_prev_conceal
				vim.b[a.buf]._anchor_prev_conceal = nil
			end
		end,
	})
end

return M
