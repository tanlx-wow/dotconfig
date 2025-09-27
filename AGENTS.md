# Agent Guidelines for dotconfig_repo

## Overview
This is a personal dotfiles repository containing configuration files for various terminal tools, editors, and system utilities. No build/test/lint commands are available as this is a configuration-only repository.

## Repository Structure
- `nvim/` - Neovim configuration (Lua-based)
- `wezterm/` - WezTerm terminal emulator config
- `zsh/` - Zsh shell configuration and aliases
- `tmux/` - Tmux configuration
- `yazi/` - File manager configuration
- `lazygit/` - Git TUI configuration
- Other tool configs: `karabiner/`, `raycast/`, `fastfetch/`, `htop/`, etc.

## Code Style Guidelines

### Lua Files (Neovim)
- Use 2-space indentation (tabs converted to spaces)
- Snake_case for variable names
- Double quotes for strings
- Comment format: `-- comment text`
- Local variables preferred: `local opt = vim.opt`
- Return tables for plugin configurations

### Shell Scripts
- Use `#!/bin/bash` or appropriate shebang
- Double quotes for variables: `"$variable"`
- Lowercase function names with underscores
- Comments start with `#`
- Use `local` for function variables

### Configuration Files
- Follow each tool's native format (TOML, YAML, JSON, etc.)
- Maintain consistent indentation within each file
- Use descriptive comments where supported