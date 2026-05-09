#!/bin/bash

SYNC_SCRIPT="$HOME/.config/shell_tool/symlink_note_update.sh"

# YOUR MASTER LIST - Update this only!
WATCH_LIST=(
  "$HOME/TLXwork/SFTP"
  "$HOME/TLXwork/Project_active"
  "$HOME/TLXwork/Project_finished"
)

echo "Watching: ${WATCH_LIST[*]}"

fswatch -o -r -l 5 \
  --event Created --event Removed --event Renamed \
  "${WATCH_LIST[@]}" | while read -r event_count; do

  # We pass the same list directly to the sync script here
  bash "$SYNC_SCRIPT" "${WATCH_LIST[@]}"

done
