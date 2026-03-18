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

# ep() {
#   # 1. Dynamically get the home directory
#   local ekphos_home=$(ekphos -d)
#
#   # 2. Create a temporary reference file right BEFORE editing
#   local ref_file=$(mktemp)
#
#   # Check if no arguments were passed to the function
#   if [[ $# -eq 0 ]]; then
#     # Quietly ensure the relative symlink exists at the root
#     # -r: relative, -s: symbolic, -f: force (overwrites if broken)
#     ln -rsf "$ekphos_home/home/Home.md" "$ekphos_home/Home.md"
#
#     # Anchor the editor to the root directory, then open the specific file
#     set -- "$ekphos_home" "+edit $ekphos_home/home/Home.md"
#   fi
#
#   # 3. Open the editor
#   ekphos "$@"
#
#   # 4. Find all markdown files modified AFTER the reference file was created
#   local modified_files=()
#   while IFS= read -r -d $'\0' file; do
#     modified_files+=("$file")
#   done < <(find -L "$ekphos_home" -type f -name "*.md" -newer "$ref_file" -print0)
#
#   # 5. Clean up the invisible temporary file
#   rm -f "$ref_file"
#
#   # 6. Loop through whatever was modified and format it
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

ep() {
  # 1. Dynamically get the home directory
  local ekphos_home=$(ekphos -d)

  # 2. Safely check connection to GitHub BEFORE pulling
  # Using curl with a 2-second timeout prevents the script from hanging
  if [[ -d "$ekphos_home/.git" ]]; then
    if curl -sI --connect-timeout 2 https://github.com >/dev/null; then
      echo "Pulling latest updates..."
      git -C "$ekphos_home" pull -q
    else
      echo "Offline mode: Skipping pull."
    fi
  fi

  # 3. Create a temporary reference file right BEFORE editing
  local ref_file=$(mktemp)

  # 4. Check if no arguments were passed to the function
  if [[ $# -eq 0 ]]; then
    set -- "$ekphos_home/home/home.md"
  fi

  # 5. Open the editor
  ekphos "$@"

  # 6. Find all markdown files modified AFTER the reference file was created
  local modified_files=()
  while IFS= read -r -d $'\0' file; do
    modified_files+=("$file")
  done < <(find -L "$ekphos_home" -type f -name "*.md" -newer "$ref_file" -print0)

  # 7. Clean up the invisible temporary file
  rm -f "$ref_file"

  # 8. Loop through whatever was modified, format, and then AUTO-SYNC
  if [[ ${#modified_files[@]} -gt 0 ]]; then
    for file in "${modified_files[@]}"; do
      local abs_path="${file:A}"
      echo "--- Changes detected in: $abs_path ---"

      echo "Checking spelling..."
      aspell check --dont-backup --mode=markdown "$abs_path"

      echo "Formatting..."
      prettier --write "$abs_path"
    done

    # 9. Auto-commit (Works Offline!) and conditional Push
    if [[ -d "$ekphos_home/.git" ]]; then
      echo "--- Saving changes locally ---"
      git -C "$ekphos_home" add .
      git -C "$ekphos_home" commit -q -m "Auto-update: Modified notes via ep"

      # 10. Check internet again BEFORE pushing
      if curl -sI --connect-timeout 2 https://github.com >/dev/null; then
        echo "Syncing changes to remote..."

        # 11. ONLY say complete if the push actually succeeds
        if git -C "$ekphos_home" push -q; then
          echo "Update complete!"
        else
          echo "Warning: Push failed. Changes are safely saved locally."
        fi

      else
        echo "Offline mode: Changes saved locally. They will sync next time you are online."
      fi
    fi

  else
    echo "No markdown files were modified. Skipping formatting and sync."
  fi
}
