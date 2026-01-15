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

pixi-ai() {
  pixi "$1" --manifest-path "$HOME"/MyDev/MyRepo/TrashScriptStorage_AI/pyproject.toml "${@:2}"
}

# put the container povray
export PATH="$HOME/.config/zsh/bin:$PATH"

# app id script
alias getappid="bash $HOME/.config/shell_tool/app_id.sh"

# yazi function
function y() {
  # 1. Make a temporary file to hold the "current working directory" (cwd)
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd

  # 2. Launch yazi, passing in all user arguments ($@),
  #    and tell it to write the cwd into that tmp file when it exits
  yazi "$@" --cwd-file="$tmp"

  # 3. After yazi exits, read the cwd from that tmp file
  if cwd="$(command cat -- "$tmp")" &&
    [ "$cwd" != "" ] &&
    [ "$cwd" != "$PWD" ]; then
    # If the cwd is not empty and different from your current directory,
    # then change the shell's directory to it
    builtin cd -- "$cwd"
  fi

  # 4. Clean up the tmp file
  rm -f -- "$tmp"
}

# fastfetch
fs() {
  fastfetch --logo "$(pokeget gengar --hide-name)" --logo-type data
}

# nb browse function
nbb() {
  nb b --gui
}

# nb edit and formmat
nbe() {
  # 1. Open the file in the editor
  nb edit "$@"

  # 2. Get the clean path for the item you just edited.
  # 'nb show --path' returns the absolute path without the [9] index.
  local filepath=$(nb show --path "$@")

  # 3. Check if the file exists, then run Prettier
  if [[ -f "$filepath" ]]; then
    echo "Formatting: $filepath"
    prettier --write "$(readlink "$filepath")"
  else
    echo "Error: Could not find file path to format."
  fi
}
