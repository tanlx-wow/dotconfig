update-code-cli() {
  # 1. Ask for sudo upfront (will be silent if you authenticated recently)
  if ! sudo -v; then
    echo "Authentication failed. Exiting."
    return 1
  fi

  echo "Checking for VS Code CLI updates..."
  local url='https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-x64'
  local tmp_file="/tmp/vscode_cli.tar.gz"

  echo "Downloading the latest version..."

  # Added -f (fail on server error) and -# (show progress bar)
  if curl -fLk -# "$url" -o "$tmp_file"; then

    # SANITY CHECK: Verify the downloaded file is a valid gzip archive
    if ! tar -tzf "$tmp_file" >/dev/null 2>&1; then
      echo "Error: Downloaded file is invalid. Microsoft's server might have sent an error page."
      rm -f "$tmp_file"
      return 1
    fi

    echo "Download verified. Extracting to /usr/local/bin/..."

    # Extract using the cached sudo permissions
    if sudo tar -xzf "$tmp_file" -C /usr/local/bin/; then
      echo "Success! VS Code CLI has been updated."
      rm -f "$tmp_file"

      echo -n "New version: "
      code --version | head -n 1
    else
      echo "Error: Extraction failed."
      rm -f "$tmp_file"
      return 1
    fi
  else
    echo "Error: Download failed entirely. Check your internet or the URL."
    return 1
  fi
}
