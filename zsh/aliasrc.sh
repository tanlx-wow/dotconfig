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
  local ekphos_home=$(ekphos -d)

  # 2. Create a temporary reference file right BEFORE editing
  # This file's creation time serves as our timestamp snapshot
  local ref_file=$(mktemp)

  # Check if no arguments were passed to the function
  if [[ $# -eq 0 ]]; then
    # Use the dynamically grabbed base directory to build the path
    set -- "$ekphos_home"
  fi

  # 3. Open the editor
  ekphos "$@"

  # 4. Find all markdown files modified AFTER the reference file was created
  # -L: Tells 'find' to follow symlinks into folders
  # -type f: Only look for actual files, not directories
  # -name "*.md": Only check markdown files (adjust if you use .txt)
  # -newer "$ref_file": The magic flag that compares timestamps
  local modified_files=()
  while IFS= read -r -d $'\0' file; do
    modified_files+=("$file")
  done < <(find -L "$ekphos_home" -type f -name "*.md" -newer "$ref_file" -print0)

  # 5. Clean up the invisible temporary file
  rm -f "$ref_file"

  # 6. Loop through whatever was modified and format it
  if [[ ${#modified_files[@]} -gt 0 ]]; then
    for file in "${modified_files[@]}"; do
      # :A resolves absolute paths in Zsh
      local abs_path="${file:A}"

      echo "--- Changes detected in: $abs_path ---"

      echo "Checking spelling..."
      aspell check --dont-backup --mode=markdown "$abs_path"

      echo "Formatting..."
      prettier --write "$abs_path"
    done
  else
    echo "No markdown files were modified. Skipping formatting."
  fi
}
# ep() {
#   # 1. Dynamically get the home directory
#   local ekphos_home=$(ekphos -d)
#   local ref_file=$(mktemp)
#
#   # A flag to track if we moved directories
#   local changed_dir=0
#
#   # 2. Handle the "no argument" default behavior
#   if [[ $# -eq 0 ]]; then
#     # Jump into the root folder FIRST. This forces the editor to anchor here.
#     pushd "$ekphos_home" >/dev/null || return
#     changed_dir=1
#
#     # Use a strictly RELATIVE path so the editor doesn't try to re-root itself
#     set -- "home/Home.md"
#   fi
#
#   # 3. Open the editor
#   ekphos "$@"
#
#   # 4. Seamlessly jump back to your original folder if we moved
#   if [[ $changed_dir -eq 1 ]]; then
#     popd >/dev/null
#   fi
#
#   # 5. Find all markdown files modified AFTER the reference file was created
#   local modified_files=()
#   while IFS= read -r -d $'\0' file; do
#     modified_files+=("$file")
#   done < <(find -L "$ekphos_home" -type f -name "*.md" -newer "$ref_file" -print0)
#
#   # 6. Clean up the invisible temporary file
#   rm -f "$ref_file"
#
#   # 7. Loop through whatever was modified and format it
#   if [[ ${#modified_files[@]} -gt 0 ]]; then
#     for file in "${modified_files[@]}"; do
#       # :A resolves absolute paths in Zsh
#       local abs_path="${file:A}"
#
#       echo "--- Changes detected in: $abs_path ---"
#
#       echo "Checking spelling..."
#       aspell check --dont-backup --mode=markdown "$abs_path"
#
#       echo "Formatting..."
#       prettier --write "$abs_path"
#     done
#   else
#     echo "No markdown files were modified. Skipping formatting."
#   fi
# }
