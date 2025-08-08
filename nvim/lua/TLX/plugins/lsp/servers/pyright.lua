return function(capabilities)
	local cwd = vim.fn.getcwd()
	local pixi_python = cwd .. "/.pixi/envs/default/bin/python"

	local function detect_python_version(python)
		local handle =
			io.popen(python .. " -c 'import sys; print(f\"{sys.version_info.major}.{sys.version_info.minor}\")'")
		if not handle then
			return "3"
		end
		local version = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return version
	end

	local python_version = detect_python_version(pixi_python)

	require("lspconfig").pyright.setup({
		capabilities = capabilities,
		settings = {
			python = {
				pythonPath = pixi_python,
				venv = "default",
				venvPath = ".pixi/envs",
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
					extraPaths = {
						string.format(".pixi/envs/default/lib/python%s/site-packages", python_version),
					},
				},
			},
		},
	})
end
