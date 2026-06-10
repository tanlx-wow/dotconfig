update-code-cli() {
  echo "Checking for VS Code CLI updates..."

  local url='https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-x64'
  local tmp_file="/tmp/vscode_cli.tar.gz"

  echo "Downloading the latest version..."

  # 1. Download to a temporary file first (no sudo needed for /tmp)
  if curl -Lk "$url" -o "$tmp_file"; then
    echo "Download complete. Extracting..."

    # 2. Extract the downloaded file to the binary folder
    if sudo tar -xzf "$tmp_file" -C /usr/local/bin/; then
      echo "Success! VS Code CLI has been updated."

      # 3. Clean up the temporary file
      rm "$tmp_file"

      # 4. Print the new version info
      echo -n "New version: "
      code --version | head -n 1
    else
      echo "Error: Extraction failed. Check your sudo permissions."
      # Clean up the file even if extraction fails
      rm -f "$tmp_file"
      return 1
    fi
  else
    echo "Error: Download failed. Check your internet connection."
    return 1
  fi
}
