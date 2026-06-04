return {
	"hedyhli/outline.nvim",
	config = function()
		--  toggle outline
		vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

		require("outline").setup({
			outline_window = {
				width = 20,
				relative_width = true,
			},
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
