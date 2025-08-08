-- ~/.config/nvim/lua/TLX/plugins/lsp/servers/pyright.lua
return function(capabilities)
	local python_path = vim.fn.getcwd() .. "/.pixi/envs/default/bin/python"

	local function get_python_version(python)
		local handle =
			io.popen(python .. " -c \"import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')\"")
		if not handle then
			return "3.12"
		end
		local version = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return version
	end

	local version = get_python_version(python_path)

	require("lspconfig").pyright.setup({
		capabilities = capabilities,
		settings = {
			python = {
				pythonPath = python_path,
				venv = "default",
				venvPath = ".pixi/envs",
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
					extraPaths = {
						string.format(".pixi/envs/default/lib/python%s/site-packages", version),
					},
				},
			},
		},
	})
end
