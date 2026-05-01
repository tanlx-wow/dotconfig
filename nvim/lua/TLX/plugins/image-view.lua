return {
	"3rd/image.nvim",
	config = function()
		require("image").setup({
			backend = "kitty", -- supported backends: "kitty", "ueberzug", "sixel"
			processor = "magick_cli", -- or "magick_rock"
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = true,
					only_render_image_at_cursor_mode = "popup", -- "popup" or "inline"
					floating_windows = false, -- if true, images will be rendered in floating markdown windows
					filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
				},
				asciidoc = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = true,
					only_render_image_at_cursor_mode = "popup",
					floating_windows = false,
					filetypes = { "asciidoc", "adoc" },
				},
				neorg = {
					enabled = true,
					filetypes = { "norg" },
				},
				rst = {
					enabled = true,
				},
				typst = {
					enabled = true,
					filetypes = { "typst" },
				},
				html = {
					enabled = false,
				},
				css = {
					enabled = false,
				},
			},
			max_width = 50,
			max_height = 20,
			max_width_window_percentage = 50,
			max_height_window_percentage = 25,
			scale_factor = 0.3,
			window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
			editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
			tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
			hijack_file_patterns = {}, -- disable auto-hijack to avoid lag when opening large image files directly
		})
	end,
}
