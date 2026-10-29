# dotconfig_repo

A personal dotfiles repository containing configuration files for terminal tools, editors, and macOS productivity applications.

## 🚀 Features

- **Neovim** - Modern Lua-based configuration with LSP, plugins, and custom keybindings
- **WezTerm** - GPU-accelerated terminal with custom themes and settings
- **Zsh** - Enhanced shell with aliases, history, FZF integration, and P10k prompt
- **Tmux** - Terminal multiplexer with vim navigation and Tokyo Night theme
- **Yazi** - Modern file manager with custom themes and configurations
- **Lazygit** - Git TUI with minimal configuration
- **macOS Tools** - Karabiner, Raycast scripts, and window management utilities

## 📁 Structure

```
├── nvim/           # Neovim configuration (Lua-based)
├── wezterm/        # WezTerm terminal emulator
├── zsh/            # Zsh shell with aliases and functions
├── tmux/           # Tmux terminal multiplexer
├── yazi/           # File manager with Tokyo Night theme
├── lazygit/        # Git TUI configuration
├── karabiner/      # macOS keyboard customization
├── raycast/        # Raycast productivity scripts
├── shell_tool/     # Custom shell scripts and utilities
├── fastfetch/      # System information display
├── bat/            # Syntax highlighting themes
├── htop/           # System monitor configuration
└── thefuck/        # Command correction tool
```

## 🛠 Key Tools & Dependencies

### Core Terminal Stack
- **Neovim** (>= 0.9) - Text editor
- **WezTerm** - Terminal emulator
- **Zsh** - Shell
- **Tmux** - Terminal multiplexer

### File Management
- **Yazi** - File manager
- **eza** - Modern `ls` replacement
- **fd** - Fast file finder
- **fzf** - Fuzzy finder

### Development Tools
- **Lazygit** - Git TUI
- **Fastfetch** - System info
- **bat** - Syntax-highlighted `cat`
- **thefuck** - Command correction

### macOS Specific
- **Karabiner-Elements** - Keyboard customization
- **Raycast** - Productivity launcher

## ⚙️ Installation

1. **Clone the repository:**
   ```bash
   git clone <repo-url> ~/.config
   ```

2. **Symlink configurations:**
   ```bash
   # Example for key configs
   ln -sf ~/.config/nvim ~/.config/nvim
   ln -sf ~/.config/wezterm ~/.config/wezterm
   ln -sf ~/.config/zsh/dotzshrc.zsh ~/.zshrc
   ```

3. **Install dependencies:**
   ```bash
   # macOS with Homebrew
   brew install neovim wezterm tmux yazi lazygit fastfetch bat eza fd fzf zoxide thefuck
   ```

## 🎨 Themes

This configuration uses a consistent **Tokyo Night** theme across:
- Neovim colorscheme
- WezTerm colors
- Tmux theme
- Yazi file manager
- Bat syntax highlighting

## 🔧 Shell Features

### Aliases & Functions
- `v` → `nvim`
- `lag` → `lazygit`
- `fs` → `fastfetch --logo nixos`
- `y()` → Yazi with directory changing
- `pwdcp` → Copy current path to clipboard

### Key Integrations
- **FZF** with `fd` for fast file searching
- **Zoxide** for smart directory jumping
- **P10k** prompt for beautiful shell prompt
- **History optimization** with deduplication

## 🪟 Window Management

Use `swift ~/.config/shell_tool/tilt_window_arg.swift <command>` for macOS window management:
- `left`, `right`, `up`, `bottom` - Tile the front window to a screen half
- `max`, `plus`, `reset`, `center` - Resize or center the front window (default: `reset`)
- `all-half` - Tile eligible windows to the left half of their current screens
- `all-max` - Maximize eligible windows on their current screens
- `hide-others` - Hide other apps using visibility and stacking detection
- `--help` - Show all commands and aliases
- Alfred integration for quick access

## 📝 Notes

- Configuration follows XDG Base Directory specification
- Neovim uses Lua for modern plugin management
- Shell configuration supports both macOS and Linux
- All tools configured with consistent themes and keybindings

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to:
- Fork and adapt for your own use
- Suggest improvements via issues
- Share your own configurations

---

*"The best dotfiles are the ones that make your daily workflow effortless."*
