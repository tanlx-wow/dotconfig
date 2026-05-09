return {
	"hedyhli/outline.nvim",
	config = function()
		--  toggle outline
		vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

		require("outline").setup({
			-- setup opts here (leave empty to use defaults)
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
	end,
}
