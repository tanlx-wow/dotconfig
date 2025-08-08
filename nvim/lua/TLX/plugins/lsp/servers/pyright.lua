local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

-- Try to find pixi python for this project
local function get_pixi_python()
	local pixi_python = "./.pixi/envs/default/bin/python3"
	if vim.fn.filereadable(pixi_python) == 1 then
		return vim.fn.resolve(pixi_python)
	end
	return nil
end

local function get_pixi_site_packages()
	local pixi_python = get_pixi_python()
	if pixi_python then
		local output = vim.fn.systemlist(pixi_python .. [[ -c "import site; print(site.getsitepackages()[0])"]])
		if output[1] and output[1] ~= "" then
			return output[1]
		end
	end
	return nil
end

local pixi_python = get_pixi_python()
local site_packages = get_pixi_site_packages()

lspconfig.pyright.setup({
	settings = {
		python = {
			analysis = {
				pythonPath = pixi_python or vim.fn.exepath("python3"),
				extraPaths = site_packages and { site_packages } or {},
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace",
				reportMissingImports = false,
			},
		},
	},
	root_dir = util.root_pattern(".git", "pyproject.toml", "pyrightconfig.json"),
})
