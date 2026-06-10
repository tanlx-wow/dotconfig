return {
	"hedyhli/outline.nvim",
	config = function()
		local outline_width_percentage = 20

		--  toggle outline
		vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

		require("outline").setup({
			outline_window = {
				width = outline_width_percentage,
				relative_width = true,
			},
		})

		vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
			group = vim.api.nvim_create_augroup("OutlineResize", { clear = true }),
			desc = "Resize outline window when nvim window got resized",
			callback = function()
				local ok, outline = pcall(require, "outline")
				if not ok or not outline.is_open() then
					return
				end

				local sidebar = outline._get_sidebar(false)
				local win = sidebar and sidebar.view and sidebar.view.win

				if not win or not vim.api.nvim_win_is_valid(win) then
					return
				end

				local width = math.ceil(vim.o.columns * (outline_width_percentage / 100))
				if vim.api.nvim_win_get_width(win) ~= width then
					vim.api.nvim_win_set_width(win, width)
				end
			end,
		})

		-- NEW: Automatically open the outline for Markdown files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				-- Use OutlineOpen instead of Outline so it doesn't accidentally
				-- toggle it closed if it's already open
				vim.cmd("OutlineOpen")
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
