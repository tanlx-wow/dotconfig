# fastfetch 
alias fs="fastfetch --logo nixos"
fs

# eza (better ls function)

alias ls="eza --icons=always --git --color=always"
# list all function
alias ll="ls -lh"

alias vmd="csh /Applications/VMD\ 1.9.4a57-arm64-Rev12.app/Contents/MacOS/startup.command.csh"

  [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"


# copy the current absoulte path 
alias pwdcp="pwd | tr -d '\n' | pbcopy"

# clear screen
alias cl="clear"
# nvim
alias v="nvim"
# lazygit
alias lag="lazygit"

# windows size
alias winsize="swift $HOME/.config/shell_tool/resize_windows.swift"

# micromamba 
# alias mamba="micromamba"

# reload zshrc
alias zshrl="source ~/.zshrc"

# output pixi env of trashstorage
pixi-trash() {
  pixi "$1" --manifest-path "$HOME"/MyDev/MyRepo/TrashScriptStorage/pyproject.toml "${@:2}"
}

# home-manager quick insatll
alias home-switch="$HOME/MyDev/MyRepo/nix_env/home-switch.sh"

# put the container povray
export PATH="$HOME/.config/zsh/bin:$PATH"

# app id script
alias getappid="bash $HOME/.config/shell_tool/app_id.sh"
