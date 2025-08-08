return function(capabilities)
	local lspconfig = require("lspconfig")
	local cwd = vim.fn.getcwd()
	local python_bin = cwd .. "/.pixi/envs/default/bin/python3"

	-- Get Python site-packages path dynamically

	local function get_site_packages(pybin)
		local handle = io.popen(pybin .. [[ -c "import site; print(site.getsitepackages()[0])"]])
		if not handle then
			return nil
		end
		local result = handle:read("*a")
		handle:close()
		return result and result:gsub("%s+$", "") or nil -- only strip trailing newline, not full path
	end
	local function get_py_version(pybin)
		local handle = io.popen(
			pybin .. [[ -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))"]]
		)
		if not handle then
			return nil
		end
		local version = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return version
	end

	local py_version = get_py_version(python_bin)
	local site_packages = get_site_packages(python_bin)

	if not py_version or not site_packages then
		vim.notify("[pyright] Could not detect Pixi Python version or site-packages", vim.log.levels.ERROR)
		return
	end

	lspconfig.pyright.setup({
		capabilities = capabilities,
		root_dir = lspconfig.util.root_pattern("pyproject.toml", ".git", "requirements.txt"),
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
					pythonPath = python_bin,
					extraPaths = { site_packages },
				},
			},
		},
	})

	vim.notify("✅ Configured Pyright with Python " .. py_version .. " from Pixi", vim.log.levels.INFO)
end
