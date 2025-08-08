local uv = vim.loop

-- function to detect Python version from Pixi env
local function get_python_version(python_path)
	local handle =
		io.popen(python_path .. " -c \"import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')\"")
	if handle then
		local version = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return version
	end
end

local pixi_python = vim.fn.getcwd() .. "/.pixi/envs/default/bin/python"
local py_ver = get_python_version(pixi_python)
local site_packages = string.format(".pixi/envs/default/lib/python%s/site-packages", py_ver)

require("lspconfig").pyright.setup({
	settings = {
		python = {
			pythonPath = pixi_python,
			venv = "default",
			venvPath = ".pixi/envs",
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace",
				typeCheckingMode = "basic",
				extraPaths = { site_packages },
			},
		},
	},
})
