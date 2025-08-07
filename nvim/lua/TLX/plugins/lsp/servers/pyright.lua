return function()
	local lspconfig = require("lspconfig")

	lspconfig.pyright.setup({
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic", -- or "strict"
				},
			},
		},
	})
end
