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

				["pyright"] = function()
					local lspconfig = require("lspconfig")
					local util = require("lspconfig.util")

					lspconfig.pyright.setup({
						root_dir = util.root_pattern("pixi.toml", "pyproject.toml", ".git"),
						before_init = function(_, config)
							local root = util.root_pattern("pixi.toml", "pyproject.toml", ".git")(vim.fn.expand("%:p"))
							local pixi_python = root .. "/.pixi/envs/default/bin/python"
							print("[pyright] injecting pythonPath: " .. pixi_python)

							if vim.fn.executable(pixi_python) == 1 then
								config.settings = config.settings or {}
								config.settings.python = config.settings.python or {}
								config.settings.python.pythonPath = pixi_python
							else
								vim.notify("[pyright] Pixi Python not found: " .. pixi_python, vim.log.levels.WARN)
							end
						end,
						settings = {
							python = {
								analysis = {
									autoSearchPaths = true,
									diagnosticMode = "openFilesOnly",
									useLibraryCodeForTypes = true,
								},
							},
						},
					})
				end,
				-- -- 🔧 Custom setup for pyright
				-- ["pyright"] = function()
				-- 	require("plugins.lsp.servers.pyright")() -- 👈 your custom file
				-- end,
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
