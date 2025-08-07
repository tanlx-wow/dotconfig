local util = require("lspconfig.util")

return {
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},

	root_dir = util.root_pattern("pixi.toml", "pyproject.toml", ".git"),

	before_init = function(_, config)
		local root = config.root_dir or vim.fn.getcwd()
		local pixi_python = root .. "/.pixi/envs/default/bin/python"

		if vim.fn.executable(pixi_python) == 1 then
			config.settings.python.pythonPath = pixi_python
		else
			vim.notify("[pyright] Pixi Python not found: " .. pixi_python, vim.log.levels.WARN)
		end
	end,
}
