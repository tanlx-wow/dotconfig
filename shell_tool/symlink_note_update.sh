#!/bin/bash

# The base of your Hub - every linked folder will be recreated inside here
HUB_ROOT="$HOME/MyNote/home"

# Function to process and link files
sync_projects() {
  local src_dir="$1"

  # This automatically determines the hub folder name based on the source folder name
  local folder_name=$(basename "$src_dir")

  # Modified: Appends "_note" to the destination folder name
  local hub_base="$HUB_ROOT/${folder_name}_note"
  local total_links=0

  # Ensure the base hub directory exists
  mkdir -p "$hub_base"

  # Find all .md files (handles any depth)
  while IFS= read -r -d $'\0' file; do
    relative_path="${file#$src_dir/}"
    dest_dir="$hub_base/$(dirname "$relative_path")"

    mkdir -p "$dest_dir"
    ln -srf "$file" "$dest_dir/"
    ((total_links++))
  done < <(find "$src_dir" -type f -name "*.md" -print0 2>/dev/null)

  echo "$total_links"
}

echo "--- Starting Sync ---"

# 1. Clean broken links across the entire MyNote/home tree
find "$HUB_ROOT" -xtype l -delete 2>/dev/null

# 2. Loop through every argument passed to the script
grand_total=0
for dir in "$@"; do
  if [[ -d "$dir" ]]; then
    echo "Processing: $dir"
    count=$(sync_projects "$dir")
    grand_total=$((grand_total + count))
  else
    echo "Warning: $dir is not a valid directory. Skipping."
  fi
done

echo "--- Summary ---"
echo "Successfully mirrored $grand_total files into $HUB_ROOT"
