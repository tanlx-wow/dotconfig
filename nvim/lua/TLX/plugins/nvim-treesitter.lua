return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		opts = {
			-- enable syntax highlighting
			highlight = { enable = true },

			-- enable indentation (Fixed typo here)
			indent = { enable = true },

			-- enable autotagging
			autotag = { enable = true },

			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"python",
				"tcl",
				"rust",
				"nix",
				"latex",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		}, -- <--- This closing bracket was missing!

		config = function(_, opts)
			-- Safely load the setup depending on which version Nix gave you
			local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
			if ok then
				ts_configs.setup(opts)
			else
				require("nvim-treesitter").setup(opts)
			end

			-- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
			require("ts_context_commentstring").setup({})
		end,
	},
}
