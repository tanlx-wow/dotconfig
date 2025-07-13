-- install with yarn or npm
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && yarn install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }

		vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/lua/TLX/plugins/markdownpreview/github-markdown.css")
	end,
	ft = { "markdown" },
}
