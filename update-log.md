# Update Log

## 2026-11-05

- Added a Zsh `vmd` alias that runs VMD's startup script directly without opening another Terminal window.

## 2026-11-04

- Excluded the blank `right_gutter` buffer from scrollbar rendering to prevent an extra scrollbar from appearing in the editor after resizing; removed the unnecessary resize-delay and forced-redraw workarounds.
- Added a separate Neovim right-gutter module that reserves two columns beside wrapped editing windows and positions the scrollbar outside the text, with a `:RightGutterToggle` command.
- Fixed Karabiner's configuration JSON by merging the Hyper+C → Fn+C rule into the selected profile alongside Caps Lock → Hyper, and corrected the Caps Lock rule description.
- Enabled Karabiner event modification for the LowCorne keyboard (vendor 7504, product 24926).
- Added the left-Option device flag (`0x20`) to Swift's generated WezTerm reset shortcut because WezTerm requires it alongside the generic Option flag to recognize Alt.
- Changed Swift's generated WezTerm reset shortcut and the matching WezTerm binding to Cmd+Ctrl+Option+R; Alfred's trigger remains Option+R.
- Removed the direct WezTerm Option+R binding; Alfred handles Option+R, and Swift waits for hotkey release before sending the internal reset shortcut directly to WezTerm using an isolated event source.
- Changed Zsh's fzf directory-search shortcut from Alt+C to Alt+F, replacing Alt+F's default forward-word binding.
- Changed window-tool's `center` argument to center the focused window on its current screen without resizing it; `reset` retains its size-reset behavior.
- Added WezTerm reset error notifications and debug logging, capturing helper failures instead of silently discarding them.
- Made WezTerm reset animate resizing and centering together using its configured 120×42 grid and current cell measurements, preserving font size instead of triggering a native font/window reset.
- Removed the fixed 0.2-second delay between WezTerm's native window reset and centering.
- Shortened window-tool animations from 0.32 to 0.15 seconds for front-window and all-window commands.
- Organized shell tools into purpose-based subfolders, updated aliases and documentation, and added a local optimized window-tool build used directly by Alfred instead of launching Swift source on every trigger.

## 2026-11-03

- Migrated Neovim's scrollbar to the v2 `refactor/v2` branch and provider options, replacing the removed hlslens search bridge with native search marks while preserving hlslens and search keymaps.
- Aligned Fastfetch bottom borders with the 52-column section title borders.
- Matched Fastfetch section titles and borders to their table label colors: green Hardware, yellow Software, and magenta Uptime.
- Added a colored Pac-Man-and-ghosts footer and current-user login time to Fastfetch's Uptime section.
- Combined Fastfetch Nix and Homebrew package totals onto one line.
- Combined Homebrew formula and cask counts into a single Fastfetch package total.
- Added Nerd Font icons to Fastfetch system labels and adjusted key spacing to keep values aligned.
- Widened all Fastfetch section borders by approximately 30%, keeping headings centered.
- Buffered the `fs` Fastfetch wrapper so the complete colored layout appears only after scanning finishes, and forwarded command-line options.
- Split Fastfetch package counts into two compact lines for Nix totals and Homebrew formulae/casks to fit the Software section.
- Restyled Fastfetch to match the reference screenshot with an OS-specific ASCII logo and colored Hardware/Software/Uptime sections, without OS age or the bottom color bar.

## 2026-11-01

- Migrated OpenCode configuration to v2 `plugins`, `providers.settings`, and ordered `permissions` rules, preserving provider timeouts and command restrictions.
- Removed the redundant quota TUI registration and migrated quota display preferences to `opencode-quota/settings.jsonc` for OpenCode Quota v6.

## 2026-10-29

- Added shared 0.32-second animations for `all-max` and `all-half`, moving eligible windows together with the same easing and Reduce Motion support as front-window commands.
- Added `shell_tool/README.md` documenting window-management commands, examples, permissions, layout behavior, and Alfred integration.
- Merged the half-screen, maximize-all, and hide-other-app scripts into `shell_tool/tilt_window_arg.swift` with `all-half`, `all-max`, and `hide-others` commands, shared window helpers, command-line help, and updated Alfred actions.
- Added smooth 0.32-second move/resize animations to the standalone and Alfred `tilt_window_arg.swift` scripts, with gentle starts/stops, a 120 Hz update target, and support for macOS Reduce Motion.

## 2026-10-28

- Migrated OpenCode plugin, provider options, and permissions to the current configuration format.

## 2026-10-20

- Enabled the `jsonls` Neovim LSP, using the installed `vscode-json-language-server` executable.
- Updated OpenCode plugin, provider timeout, and tool-permission settings.

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
