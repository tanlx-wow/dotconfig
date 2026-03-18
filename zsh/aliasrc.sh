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

  # 2. Safely check connection to GitHub BEFORE pulling
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

  # 8. THE COMMIT PHASE: Only runs if you actually changed files today
  local needs_push=false

  if [[ ${#modified_files[@]} -gt 0 ]]; then
    for file in "${modified_files[@]}"; do
      local abs_path="${file:A}"
      echo "--- Changes detected in: $abs_path ---"

      echo "Checking spelling..."
      aspell check --dont-backup --mode=markdown "$abs_path"

      echo "Formatting..."
      prettier --write "$abs_path"
    done

    if [[ -d "$ekphos_home/.git" ]]; then
      echo "--- Saving changes locally ---"
      git -C "$ekphos_home" add .
      git -C "$ekphos_home" commit -q -m "Auto-update: Modified notes via ep"
      needs_push=true
    fi
  else
    echo "No files modified this session."
  fi

  # 9. THE PUSH PHASE: Runs if we just committed OR if we have old offline commits
  if [[ -d "$ekphos_home/.git" ]]; then
    # Check if Git says we are "ahead" of the remote repository (unpushed commits exist)
    if git -C "$ekphos_home" status -sb 2>/dev/null | grep -q 'ahead'; then
      needs_push=true
    fi

    if [[ "$needs_push" = true ]]; then
      # Check internet again BEFORE pushing
      if curl -sI --connect-timeout 2 https://github.com >/dev/null; then
        echo "Syncing pending changes to remote..."

        if git -C "$ekphos_home" push -q; then
          echo "Update complete!"
        else
          echo "Warning: Push failed. Changes remain safely saved locally."
        fi

      else
        echo "Offline mode: You have unpushed changes saved locally. They will sync next time you are online."
      fi
    else
      echo "Everything is up to date!"
    fi
  fi
}
