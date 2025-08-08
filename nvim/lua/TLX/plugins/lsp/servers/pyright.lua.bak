return function()
	local lspconfig = require("lspconfig")
	local pixi_python = vim.fn.trim(vim.fn.system("pixi run which python"))
	lspconfig.pyright.setup({
		settings = {
			python = {
				pythonPath = pixi_python,
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic", -- or "strict"
				},
				venvPath = ".pixi/envs",
				venv = "default",
			},
		},
	})
end
