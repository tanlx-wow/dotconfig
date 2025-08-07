return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"html",
				"lua_ls",
				"prismals",
				"pyright",
				"rust_analyzer",
				"bashls",
				"harper_ls",
				"marksman",
			},
			handlers = {
				-- Default handler for all other servers
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,

				-- 🔧 Custom setup for pyright
				["pyright"] = function()
					require("plugins.lsp.servers.pyright")() -- 👈 your custom file
				end,
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				"eslint_d", -- js linter
				"shellharden", --shell formatter linter
				"markdownlint", -- md formatter linter
				"nixpkgs-fmt", --nixpkgs fromatter
			},
		})
	end,
}
