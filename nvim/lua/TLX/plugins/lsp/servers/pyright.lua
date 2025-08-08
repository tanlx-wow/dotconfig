return function(capabilities)
	local cwd = vim.fn.getcwd()
	local python_bin = cwd .. "/.pixi/envs/default/bin/python"

	-- Get the absolute site-packages path
	local function get_site_packages(pybin)
		local handle = io.popen(pybin .. [[ -c "import site; print(site.getsitepackages()[0])" ]])
		if not handle then
			return nil
		end
		local path = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return path
	end

	local site_packages = get_site_packages(python_bin)

	if not site_packages then
		vim.notify("Failed to detect site-packages from " .. python_bin, vim.log.levels.ERROR)
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
					extraPaths = { site_packages },
				},
			},
		},
	})
end
