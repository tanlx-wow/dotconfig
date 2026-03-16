#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh" # Loads all defined colors

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

FOCUSED_WORKSPACE="${FOCUSED_WORKSPACE:-$AEROSPACE_FOCUSED_WORKSPACE}"

if [ -z "$FOCUSED_WORKSPACE" ]; then
	FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

if [ "$FOCUSED_WORKSPACE" = "$SID" ]; then
	sketchybar --animate tanh 5 --set "$NAME" \
		icon.color="$RED" \
		icon="${SPACE_ICONS[$SID - 1]}"
else
	sketchybar --animate tanh 5 --set "$NAME" \
		icon.color="$COMMENT" \
		icon="${SPACE_ICONS[$SID - 1]}"
fi
