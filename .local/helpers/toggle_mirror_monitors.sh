#!/usr/bin/env bash

# Requirements: hyprctl, jq, fzf
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || { echo "hyprctl not found"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found"; exit 1; }
command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; exit 1; }

MIRRORED=$(hyprctl monitors all -j | jq -r '.[] | select(.mirrorOf != "none") | .name')

if [ -n "$MIRRORED" ]; then
  echo "Detected mirrored monitors: $MIRRORED"
  for MON in $MIRRORED; do
    echo "Restoring $MON..."
    hyprctl keyword monitor "$MON,preferred,auto,1"
  done
  echo "✅ Mirroring removed."
else
  echo "No mirrored monitors detected."
  echo

  # Get all monitors
  MONITORS_JSON=$(hyprctl monitors all -j)
  mapfile -t MONITORS < <(echo "$MONITORS_JSON" | jq -r '.[].name')

  if [ "${#MONITORS[@]}" -lt 2 ]; then
    echo "❌ Need at least two monitors to create a mirror."
    exit 1
  fi

  echo "Pick the monitor you want to mirror *from* (source):"
  SOURCE=$(printf '%s\n' "${MONITORS[@]}" | fzf --prompt="Source monitor> " --height=8 --reverse) || exit 1

  echo "Pick the monitor you want to mirror *to* (target):"
  TARGET=$(printf '%s\n' "${MONITORS[@]}" | grep -v "$SOURCE" | fzf --prompt="Target monitor> " --height=8 --reverse) || exit 1
 
  # Fetch mode and scale from the source so the target uses the same
  MODE=$(echo "$MONITORS_JSON" | jq -r --arg n "$SOURCE" '.[] | select(.name == $n) | "\(.width)x\(.height)@\(.refreshRate)"')
  SCALE=$(echo "$MONITORS_JSON" | jq -r --arg n "$SOURCE" '.[] | select(.name == $n) | .scale')

  echo "Mirroring $TARGET -> $SOURCE ..."
  hyprctl keyword monitor "$TARGET,${MODE},auto,${SCALE},mirror,$SOURCE"
fi

