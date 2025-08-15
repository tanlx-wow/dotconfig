-- cursor-aware HTML anchor overlay for Markdown
local M = {}
local ns = vim.api.nvim_create_namespace("md_html_anchor_overlay")

local function find_anchor(line)
	-- support name="..." or id="..." with single/double quotes
	local s, e, id = line:find("<a%s+name=['\"]([^'\"]+)['\"]></a>")
	if not s then
		s, e, id = line:find("<a%s+id=['\"]([^'\"]+)['\"]></a>")
	end
	return s, e, id
end

local function paint_line(buf, row, opts)
	local line = (vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or "")
	local s, e, id = find_anchor(line)
	if s and e and id and #id > 0 then
		local ext = {
			end_col = e,
			virt_text = { { (opts.icon or "󰌹 ") .. id, opts.highlight or "RenderMarkdownLink" } },
			virt_text_pos = "overlay",
			priority = 120,
		}
		if opts.conceal ~= false then
			ext.hl_group = "Conceal"
			ext.conceal = ""
		end
		vim.api.nvim_buf_set_extmark(buf, ns, row, s - 1, ext)
	end
end

local function paint_all(buf, opts)
	if vim.bo[buf].filetype ~= "markdown" then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local n = vim.api.nvim_buf_line_count(buf)
	for row = 0, n - 1 do
		if row ~= cur_row then
			paint_line(buf, row, opts)
		end
	end
end

local function clear_line(buf, row)
	-- remove any extmarks on this exact line
	local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, {})
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_del_extmark(buf, ns, m[1])
	end
end

function M.setup(opts)
	opts = opts or {}
	local grp = vim.api.nvim_create_augroup("MdHtmlAnchorOverlayCursorAware", { clear = true })

	-- Initial paint / repaint on text changes (except while typing)
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged" }, {
		group = grp,
		pattern = { "*.md", "*.markdown" },
		callback = function(a)
			if vim.bo[a.buf].filetype == "markdown" and not vim.fn.mode():match("i") then
				paint_all(a.buf, opts)
			end
		end,
	})

	-- While typing: show raw text (no overlays) and no conceal
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = grp,
		pattern = { "*.md", "*.markdown" },
		callback = function()
			if vim.bo.filetype == "markdown" then
				vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
				vim.b._anchor_prev_conceal = vim.b._anchor_prev_conceal or vim.opt_local.conceallevel:get()
				vim.opt_local.conceallevel = 0
			end
		end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = grp,
		pattern = { "*.md", "*.markdown" },
		callback = function()
			if vim.bo.filetype == "markdown" then
				vim.opt_local.conceallevel = vim.b._anchor_prev_conceal or 2
				paint_all(0, opts)
			end
		end,
	})

	-- Cursor-based rendering: remove overlay on current line, add back on previous line
	local last_row
	local function on_move()
		if vim.bo.filetype ~= "markdown" or vim.fn.mode():match("i") then
			return
		end
		local buf = 0
		local row = vim.api.nvim_win_get_cursor(0)[1] - 1
		if last_row ~= nil and last_row ~= row then
			-- re-paint previous line if it has an anchor
			clear_line(buf, last_row)
			paint_line(buf, last_row, opts)
		end
		-- ensure current line is raw
		clear_line(buf, row)
		last_row = row
	end

	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = grp,
		pattern = { "*.md", "*.markdown" },
		callback = on_move,
	})

	-- Restore original conceal when leaving buffer
	vim.api.nvim_create_autocmd("BufLeave", {
		group = grp,
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
