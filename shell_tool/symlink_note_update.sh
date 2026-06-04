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
  local created_links=0
  local skipped_links=0

  # Ensure the base hub directory exists
  mkdir -p "$hub_base"

  # Find all .md files (handles any depth)
  while IFS= read -r -d $'\0' file; do
    local relative_path="${file#$src_dir/}"
    local dest_path="$hub_base/$relative_path"
    local dest_dir

    dest_dir=$(dirname "$dest_path")

    mkdir -p "$dest_dir"

    if [[ -L "$dest_path" && "$(readlink "$dest_path")" == "$file" ]]; then
      ((skipped_links++))
      continue
    fi

    if [[ -e "$dest_path" && ! -L "$dest_path" ]]; then
      echo "Warning: $dest_path exists and is not a symlink. Skipping." >&2
      ((skipped_links++))
      continue
    fi

    ln -sf "$file" "$dest_path"
    ((created_links++))
    ((total_links++))
  done < <(find "$src_dir" -type f -name "*.md" -print0 2>/dev/null)

  echo "$created_links $skipped_links"
}

echo "--- Starting Sync ---"

# 1. Clean broken links across the entire MyNote/home tree
find "$HUB_ROOT" -xtype l -delete 2>/dev/null

# 2. Loop through every argument passed to the script
grand_total=0
grand_skipped=0
for dir in "$@"; do
  if [[ -d "$dir" ]]; then
    echo "Processing: $dir"
    read -r count skipped < <(sync_projects "$dir")
    grand_total=$((grand_total + count))
    grand_skipped=$((grand_skipped + skipped))
  else
    echo "Warning: $dir is not a valid directory. Skipping."
  fi
done

echo "--- Summary ---"
echo "Created or updated $grand_total links into $HUB_ROOT"
echo "Skipped $grand_skipped existing links"
