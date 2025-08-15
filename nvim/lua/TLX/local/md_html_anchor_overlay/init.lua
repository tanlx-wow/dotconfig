-- ~/.config/nvim/lua/local/md_html_anchor_overlay/init.lua
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

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		for i, line in ipairs(lines) do
			-- support name="..." or id="..." (single or double quotes)
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

	-- Paint on open/change
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
		pattern = { "*.md", "*.markdown" },
		callback = function(a)
			if vim.bo[a.buf].filetype == "markdown" then
				paint(a.buf)
			end
		end,
	})

	-- === Conceal behavior: render in normal mode, show raw in insert ===

	local group = vim.api.nvim_create_augroup("MdHtmlAnchorConceal", { clear = false })

	-- When we enter a markdown buffer, remember the user's conceallevel & enable rendering
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "markdown",
		callback = function(a)
			-- Save previous per-buffer setting once
			if vim.b[a.buf]._anchor_prev_conceal == nil then
				vim.b[a.buf]._anchor_prev_conceal = vim.opt_local.conceallevel:get()
			end
			-- Render while not inserting
			vim.opt_local.conceallevel = 2
			vim.opt_local.concealcursor = "nc"
			paint(a.buf)
		end,
	})

	-- Turn OFF conceal while editing (show raw <a ...></a>)
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			if vim.bo.filetype == "markdown" then
				vim.opt_local.conceallevel = 0
			end
		end,
	})

	-- Turn conceal back ON when leaving insert (and repaint overlays)
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			if vim.bo.filetype == "markdown" then
				vim.opt_local.conceallevel = 2
				paint(0)
			end
		end,
	})

	-- On buffer leave, restore original conceallevel
	vim.api.nvim_create_autocmd("BufLeave", {
		group = group,
		callback = function(a)
			if vim.bo[a.buf].filetype == "markdown" and vim.b[a.buf]._anchor_prev_conceal ~= nil then
				vim.opt_local.conceallevel = vim.b[a.buf]._anchor_prev_conceal
				vim.b[a.buf]._anchor_prev_conceal = nil
			end
		end,
	})
end

return M
