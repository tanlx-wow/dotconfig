#!/bin/bash

# 1. Default settings
DRY_RUN=false
DEST_DIR=""
SRC_DIR="." # Defaults to the current directory
RECORD_FILE="saved_symlinks.txt"

# 2. Define the Help/Usage function
usage() {
  echo "Usage: $0 [OPTIONS] -t <target_destination_directory>"
  echo ""
  echo "This script scans a source directory for symlinks, records their"
  echo "absolute targets, and safely reconstructs them as accurately calculated"
  echo "relative links inside a new destination directory."
  echo ""
  echo "Options:"
  echo "  -t, --target <dir> REQUIRED: Specify the target destination directory."
  echo "  -p, --path <dir>   Specify the source directory to scan (Defaults to '.')"
  echo "  -n, --dry-run      Perform a trial run. Prints the commands that WOULD"
  echo "                     be executed without actually creating any files or folders."
  echo "  -h, --help         Display this help message and exit."
  echo ""
  echo "Example:"
  echo "  $0 -p /var/www/html -t /backup/html_links --dry-run"
}

# 3. Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | -help | --help)
    usage
    exit 0
    ;;
  --dry-run | -n)
    DRY_RUN=true
    shift
    ;;
  -t | --target)
    # Ensure the user actually provided a path after the flag
    if [ "$2" = "" ] || [[ "$2" == -* ]]; then
      echo "Error: --target requires a directory argument."
      exit 1
    fi
    DEST_DIR="$2"
    shift 2
    ;;
  -p | --path)
    # Ensure the user actually provided a path after the flag
    if [ "$2" = "" ] || [[ "$2" == -* ]]; then
      echo "Error: --path requires a directory argument."
      exit 1
    fi
    # Strip trailing slashes to keep paths clean, but keep '/' if it's the root dir
    SRC_DIR="${2%/}"
    [ "$SRC_DIR" = "" ] && SRC_DIR="/"
    shift 2
    ;;
  *)
    # Fallback: If it's not a flag, assume it's the target destination
    if [ "$DEST_DIR" = "" ]; then
      DEST_DIR="$1"
    else
      echo "Error: Unknown argument '$1'."
      usage
      exit 1
    fi
    shift
    ;;
  esac
done

# 4. Validate inputs
if [ "$DEST_DIR" = "" ]; then
  echo "Error: Missing target destination directory."
  echo "You must specify a target using -t or --target."
  echo ""
  usage
  exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Source directory '$SRC_DIR' does not exist."
  exit 1
fi

# 5. Generate the symlink record file
echo "Scanning '$SRC_DIR' for symlinks..."
find "$SRC_DIR" -type l | while read -r link; do
  echo "$link -> $(realpath "$link")"
done >"$RECORD_FILE"

# 6. Announce the current mode
if [ "$DRY_RUN" = true ]; then
  echo "--- DRY RUN MODE ENABLED ---"
  echo "No actual changes will be made."
else
  echo "--- LIVE RUN ---"
  echo "Creating symlinks..."
fi
echo "Source Path: $SRC_DIR"
echo "Target Destination: $DEST_DIR"
echo "----------------------------"

# 7. Process the symlinks
while read -r line; do
  link="${line%% -> *}"
  target="${line##* -> }"

  # Smart Path Mapping:
  # Remove the base source directory from the link path.
  clean_link="${link#$SRC_DIR}"
  clean_link="${clean_link#/}" # Strip any leftover leading slash

  new_link_path="$DEST_DIR/$clean_link"
  new_link_dir=$(dirname "$new_link_path")

  if [ "$DRY_RUN" = true ]; then
    echo "Would run: mkdir -p \"$new_link_dir\""
    echo "Would run: ln -srf \"$target\" \"$new_link_path\""
    echo ""
  else
    mkdir -p "$new_link_dir"
    ln -srf "$target" "$new_link_path"
    echo "Created: $new_link_path"
  fi

done <"$RECORD_FILE"

# 8. Cleanup
rm -f "$RECORD_FILE"

echo "Done!"
