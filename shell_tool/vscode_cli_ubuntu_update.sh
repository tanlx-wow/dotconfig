update-code-cli() {
  # 1. Ask for sudo upfront and cache the password
  echo "Please authenticate to start the update process:"
  if ! sudo -v; then
    echo "Authentication failed. Exiting."
    return 1
  fi

  echo "Checking for VS Code CLI updates..."
  local url='https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-x64'
  local tmp_file="/tmp/vscode_cli.tar.gz"

  echo "Downloading the latest version..."

  # 2. Download to a temporary file
  if curl -Lk "$url" -o "$tmp_file"; then
    echo "Download complete. Extracting to /usr/local/bin/..."

    # 3. Extract using the already-cached sudo permissions
    if sudo tar -xzf "$tmp_file" -C /usr/local/bin/; then
      echo "Success! VS Code CLI has been updated."
      rm "$tmp_file"

      echo -n "New version: "
      code --version | head -n 1
    else
      echo "Error: Extraction failed."
      rm -f "$tmp_file"
      return 1
    fi
  else
    echo "Error: Download failed. Check your internet connection."
    return 1
  fi
}
