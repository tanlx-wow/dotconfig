-- pyright.lua
return function()
	local lspconfig = require("lspconfig")
	local util = require("lspconfig.util")

	lspconfig.pyright.setup({
		root_dir = util.root_pattern("pixi.toml", "pyproject.toml", ".git"),
		before_init = function(_, config)
			local root = util.root_pattern("pixi.toml", "pyproject.toml", ".git")(vim.fn.expand("%:p"))
			local pixi_python = root .. "/.pixi/envs/default/bin/python"
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
end
