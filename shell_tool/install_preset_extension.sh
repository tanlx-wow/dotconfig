#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Install Preset Extensions (Enter Key)
# @raycast.mode silent
# Optional parameters:
# @raycast.icon 🧩

PRESET=(
 "FezVrasta/emoji"
 "mblode/quick-event"
 # "thomas/downloads-manager"
 "tonka3000/speedtest"
 # "tholanda/script-commands"
 "aiotter/nixpkgs-search"
# "lex-unix/nix-flake-templates"
)

open -ga "Raycast" || true
sleep 0.5

for slug in "${PRESET[@]}"; do
  echo "Installing $slug …"
osascript -e 'open location "raycast://extensions/FezVrasta/emoji"'
  # open the extension page
  osascript -e 'open location "raycast://extensions/'"$slug"'"'
  sleep 1.0  # give Raycast time to load the page

  # simulate hitting Enter in Raycast
  /usr/bin/osascript <<'APPLESCRIPT'
    tell application "System Events"
      tell process "Raycast"
        keystroke return
      end tell
    end tell
APPLESCRIPT

  sleep 1.0
done

echo "Done."
