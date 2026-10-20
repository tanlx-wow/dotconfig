# Update Log

## 2026-10-20

- Enabled the `jsonls` Neovim LSP, using the installed `vscode-json-language-server` executable.

## 2026-10-10

- Set WezTerm's initial size to 120 columns by 42 rows.
- Center the initial WezTerm window on the primary display via `gui_startup.lua`.
- Make WezTerm resets use its native `ResetFontAndWindowSize` action before recentering the window.
- Added a `Ctrl + Option + R` WezTerm reset shortcut for `tilt_window_arg.swift`.
- Updated `tilt_window_arg.swift` metadata for its Alfred workflow.
- Removed the Ghostty and OmniWM configurations.

## 2026-08-15

- Added the PowerKit `netspeed` module to the tmux status bar.

## 2026-06-26

- Refresh `outline.nvim` when LSP clients attach and when LSP progress completes so code symbols appear without waiting for an edit.
- Created `nvim/lua/TLX/plugins/codex-nvim.lua` for Codex Neovim integration.
- Kept `nvim-tree` on the far-left side when both `nvim-tree` and `outline.nvim` are open.
- Added max width caps for sidebar windows:
  - `nvim-tree`: 15% of editor width, capped at 30 columns.
  - `outline.nvim`: 15% of editor width, capped at 30 columns.
- Updated outline auto-open/manual toggle behavior so sidebar resizing and ordering stay consistent.
