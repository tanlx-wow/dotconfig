return function(capabilities)
	local cwd = vim.fn.getcwd()
	local python_bin = cwd .. "/.pixi/envs/default/bin/python"

	-- Dynamically detect the version (e.g., "3.13")
	local function get_py_version(pybin)
		local handle = io.popen(
			pybin .. [[ -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))" ]]
		)
		if not handle then
			return nil
		end
		local version = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return version
	end

	local py_version = get_py_version(python_bin)

	if not py_version then
		vim.notify("Failed to detect Python version from " .. python_bin, vim.log.levels.ERROR)
		return
	end

	require("lspconfig").pyright.setup({
		capabilities = capabilities,
		settings = {
			python = {
				pythonPath = python_bin,
				venv = "default",
				venvPath = ".pixi/envs",
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
					extraPaths = {
						string.format(".pixi/envs/default/lib/python%s/site-packages", py_version),
					},
				},
			},
		},
	})
end
