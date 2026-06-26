return {
	"hedyhli/outline.nvim",
	config = function()
		local outline_width_percentage = 15
		local outline_max_width = 30
		local nvim_tree_width_percentage = 15
		local nvim_tree_max_width = 30

		local function outline_width()
			return math.min(math.ceil(vim.o.columns * (outline_width_percentage / 100)), outline_max_width)
		end

		local function nvim_tree_width()
			return math.min(math.floor(vim.go.columns * (nvim_tree_width_percentage / 100)), nvim_tree_max_width)
		end

		local function move_nvim_tree_leftmost()
			local current_win = vim.api.nvim_get_current_win()
			local tree_win = nil

			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "NvimTree" then
					tree_win = win
					break
				end
			end

			if not tree_win then
				return
			end

			pcall(vim.api.nvim_set_current_win, tree_win)
			pcall(vim.cmd, "wincmd H")
			pcall(vim.api.nvim_win_set_width, 0, nvim_tree_width())

			if vim.api.nvim_win_is_valid(current_win) then
				pcall(vim.api.nvim_set_current_win, current_win)
			end
		end

		local function resize_outline()
			local ok, outline = pcall(require, "outline")
			if not ok or not outline.is_open() then
				return
			end

			local sidebar = outline._get_sidebar(false)
			local win = sidebar and sidebar.view and sidebar.view.win

			if not win or not vim.api.nvim_win_is_valid(win) then
				return
			end

			local width = outline_width()
			if vim.api.nvim_win_get_width(win) ~= width then
				vim.api.nvim_win_set_width(win, width)
			end
		end

		require("outline").setup({
			outline_window = {
				position = "left",
				width = outline_width_percentage,
				relative_width = true,
			},
		})

		--  toggle outline
		vim.keymap.set("n", "<leader>ol", function()
			local ok, outline = pcall(require, "outline")
			local was_open = ok and outline.is_open()

			pcall(vim.cmd, "Outline")

			if not was_open then
				vim.schedule(function()
					resize_outline()
					move_nvim_tree_leftmost()
				end)
			end
		end, { desc = "Toggle Outline" })

		vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
			group = vim.api.nvim_create_augroup("OutlineResize", { clear = true }),
			desc = "Resize outline window when nvim window got resized",
			callback = resize_outline,
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("OutlineAutoOpen", { clear = true }),
			pattern = {
				"bash",
				"css",
				"go",
				"html",
				"javascript",
				"javascriptreact",
				"json",
				"lua",
				"markdown",
				"nix",
				"prisma",
				"python",
				"rust",
				"sh",
				"toml",
				"typescript",
				"typescriptreact",
				"yaml",
			},
			callback = function()
				vim.schedule(function()
					pcall(vim.cmd, "OutlineOpen!")
					vim.schedule(function()
						resize_outline()
						move_nvim_tree_leftmost()
					end)
				end)
			end,
		})

		vim.api.nvim_create_autocmd("QuitPre", {
			callback = function()
				if vim.bo.filetype == "Outline" then
					return
				end

				pcall(vim.cmd, "OutlineClose")
			end,
		})
	end,
}
