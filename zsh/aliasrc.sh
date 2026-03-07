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
alias getappid="$HOME/.config/shell_tool/app_id.sh"

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
# nb edit and format
nbe() {
  # 1. Open the file for editing
  nb edit "$@"

  # 2. Get the path from nb
  local filepath=$(nb show --path "$@")

  # 3. Resolve path and format
  if [[ -f "$filepath" ]]; then
    # :A resolves the absolute path (handling symlinks automatically)
    local abs_path="${filepath:A}"

    # --- Spelling Check ---
    # We use --dont-backup to avoid cluttering your nb directory with .bak files
    echo "Checking spelling: $abs_path"
    aspell check --dont-backup --mode=markdown "$abs_path"

    # --- Formatting ---
    echo "Formatting: $abs_path"
    prettier --write "$abs_path"
  else
    echo "Error: Could not find file path to format."
  fi
}

ep() {
  # 1. Dynamically get the home directory
  local epkhos_home=$(ekphos -d)

  # 2. Construct the file path using the first argument ($1)
  local filepath="$epkhos_home/$1"

  # 3. Capture the modification time BEFORE editing
  local mtime_before=0
  if [[ -f "$filepath" ]]; then
    mtime_before=$(stat -c %Y "$filepath")
  fi

  # 4. Open the file in the editor (passing all arguments)
  ekphos "$@"

  # 5. Check the modification time AFTER editing
  if [[ -f "$filepath" ]]; then
    local mtime_after=$(stat -c %Y "$filepath")

    # 6. Compare timestamps to see if you actually saved changes
    if [[ "$mtime_after" -gt "$mtime_before" ]]; then
      local abs_path="${filepath:A}"

      echo "Changes detected in: $abs_path"

      echo "Checking spelling..."
      aspell check --dont-backup --mode=markdown "$abs_path"

      echo "Formatting..."
      prettier --write "$abs_path"
    else
      echo "No changes made to '$1'. Skipping spellcheck and formatting."
    fi
  else
    echo "Error: Could not find file at '$filepath'."
  fi
}
