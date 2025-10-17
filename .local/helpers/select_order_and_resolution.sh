#!/usr/bin/env bash
# hyprland-arrange-monitors.sh
# Interactive monitor reorder / resolution / scale tool for Hyprland using fzf + jq + hyprctl
#
# Requirements: hyprctl, jq, fzf, awk, bc
#
# Usage: ./hyprland-arrange-monitors.sh
# Key idea: choose order by picking monitors one-by-one for position 1..N

set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || { echo "hyprctl not found"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found"; exit 1; }
command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "awk not found"; exit 1; }
command -v bc >/dev/null 2>&1 || { echo "bc not found"; exit 1; }

# --- Helpers ----------------------------------------------------------------

readonly TMP_JSON="/tmp/hypr_monitors_$$.json"
trap 'rm -f "$TMP_JSON"' EXIT

# Fetch monitors JSON (all to include mirrored/disabled)
hyprctl monitors all -j > "$TMP_JSON"

# Detect mirrored monitors
mirrors=$(jq -r '.[] | select(.mirrorOf != "none") | .name' "$TMP_JSON" || true)
if [ -n "$mirrors" ]; then
  echo "Warning: mirrored monitors detected:"
  echo "$mirrors"
  read -rp "Do you want the script to unmirror them first? [y/N] " yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    # Simple unmirror: set them to prefered mode (or rebuild later)
    for m in $mirrors; do
      # attempt to restore with "preferred" fallback — user may need to adjust manually
      echo "Attempting to unmirror $m (will set 'preferred' mode for it)..."
      hyprctl keyword monitor "$m,preferred,auto,1" || true
    done
    # refresh JSON
    hyprctl monitors all -j > "$TMP_JSON"
    echo "Unmirror attempt done. Continuing..."
  else
    echo "Continuing without changing mirror state."
  fi
fi

# Build monitor list: name, description
mapfile -t MONITOR_LINES < <(jq -r '.[] | "\(.name)\t\(.description // .model // "unknown")\tmirrorOf:\(.mirrorOf)"' "$TMP_JSON")

if [ "${#MONITOR_LINES[@]}" -eq 0 ]; then
  echo "No monitors found."
  exit 1
fi

echo "Found monitors:"
for l in "${MONITOR_LINES[@]}"; do
  echo -e "  $l"
done
echo

# Provide interactive ordering: choose monitor for position 1, then 2, ...
ORDERED=()
AVAILABLE=("${MONITOR_LINES[@]}")

pos=1
while [ "${#AVAILABLE[@]}" -gt 0 ]; do
  echo "Choose monitor for position #$pos (left->right). Press Esc/Ctrl-C to cancel."
  # Show available monitors via fzf, return selection (line has "name \t desc ...")
  sel=$(printf '%s\n' "${AVAILABLE[@]}" | fzf --height=10 --reverse --border --ansi --prompt="Pos $pos> " --no-multi) || { echo "Cancelled."; exit 1; }
  name=$(awk -F'\t' '{print $1}' <<<"$sel")
  ORDERED+=("$name")
  # remove selected from AVAILABLE
  newavail=()
  for a in "${AVAILABLE[@]}"; do
    if [[ "$(awk -F'\t' '{print $1}' <<<"$a")" != "$name" ]]; then
      newavail+=("$a")
    fi
  done
  AVAILABLE=("${newavail[@]}")
  ((pos++))
done

echo
echo "Chosen order (left -> right):"
for i in "${!ORDERED[@]}"; do
  echo "  $((i+1)). ${ORDERED[i]}"
done
echo

# For each chosen monitor, prompt resolution mode (from availableModes) and scale
declare -A MON_MODE
declare -A MON_SCALE
declare -A MON_WIDTH MON_HEIGHT MON_HZ

for name in "${ORDERED[@]}"; do
  # Extract available modes for this monitor
  modes_raw=$(jq -r --arg n "$name" '.[] | select(.name == $n) | .availableModes[]?' "$TMP_JSON" | sed '/^$/d' || true)
  if [ -z "$modes_raw" ]; then
    echo "No modes found for $name; using 'preferred' fallback."
    mode_choice="preferred"
    MON_MODE[$name]="$mode_choice"
    MON_WIDTH[$name]=0
    MON_HEIGHT[$name]=0
    MON_HZ[$name]=60
  else
    # Normalize modes: keep unique strings like 1920x1080@60
    # availableModes may include duplicates or many hz variants; reduce to "WIDTHxHEIGHT@HZ"
    mapfile -t MODES_ARR < <(printf '%s\n' "$modes_raw" | awk -F'@' '{gsub(/ /,"",$1); hz=$2; sub(/Hz/,"",hz); print $1 "@" hz}' | awk '!seen[$0]++')
    echo "Choose mode for $name:"
    mode_choice=$(printf '%s\n' "${MODES_ARR[@]}" | fzf --height=12 --reverse --border --prompt="Mode for $name> " --preview "echo {}" --no-multi) || { echo "Cancelled."; exit 1; }
    # Parse resolution and hz
    res=$(awk -F'@' '{print $1}' <<<"$mode_choice")
    hz_raw=$(awk -F'@' '{print $2}' <<<"$mode_choice")
    # Some inputs may have decimals; use integer part for hyprctl
    hz=$(awk -F'.' '{print $1}' <<<"$hz_raw")
    MON_MODE[$name]="$mode_choice"
    # parse width/height from res (like 1920x1080)
    width=$(awk -Fx '{print $1}' <<<"$res")
    height=$(awk -Fx '{print $2}' <<<"$res")
    MON_WIDTH[$name]="$width"
    MON_HEIGHT[$name]="$height"
    MON_HZ[$name]="$hz"
  fi

  # Choose scale: offer presets or custom
  echo "Choose scale for $name (common presets provided; choose 'custom' to type value):"
  scale_choice=$(printf '%s\n' "1" "1.25" "1.5" "1.6" "2" "custom" | fzf --height=8 --reverse --border --prompt="Scale for $name> " --no-multi) || { echo "Cancelled."; exit 1; }
  if [ "$scale_choice" = "custom" ]; then
    read -rp "Enter custom scale (e.g. 1.15): " custom
    # basic validation: number >0
    if ! awk "BEGIN{exit !($custom > 0)}"; then
      echo "Invalid scale. Using 1."
      scale_choice="1"
    else
      scale_choice="$custom"
    fi
  fi
  MON_SCALE[$name]="$scale_choice"
  echo "-> $name: mode=${MON_MODE[$name]}, scale=${MON_SCALE[$name]}"
  echo
done

# Compute X offsets in logical coordinates: xpos[i] = sum(prev_width / prev_scale)
declare -A MON_XPOS
x_acc=0
for name in "${ORDERED[@]}"; do
  MON_XPOS[$name]="$x_acc"
  # if width is zero (preferred fallback) we attempt to compute from current monitor info
  w=${MON_WIDTH[$name]:-0}
  s=${MON_SCALE[$name]}
  if [ "$w" -eq 0 ]; then
    # try to get current resolution width from hyprctl JSON
    cur_w=$(jq -r --arg n "$name" '.[] | select(.name == $n) | .geometry[0] // .currentMode[0] // empty' "$TMP_JSON" 2>/dev/null || true)
    # fallback guess
    if [[ "$cur_w" =~ ^[0-9]+$ ]]; then
      w="$cur_w"
    else
      # fallback to 1920
      w=1920
    fi
  fi
  # compute logical width = width / scale, then round to nearest int
  logical=$(awk -v W="$w" -v S="$s" 'BEGIN{printf "%d", (W / S) + 0.5}')
  # update accumulator
  x_acc=$(awk -v X="$x_acc" -v L="$logical" 'BEGIN{printf "%d", X + L}')
done

# Confirm and apply
echo "Final layout (left -> right):"
for name in "${ORDERED[@]}"; do
  mode=${MON_MODE[$name]}
  scale=${MON_SCALE[$name]}
  xpos=${MON_XPOS[$name]}
  hz=${MON_HZ[$name]:-60}
  echo "  $name : mode=$mode , scale=$scale , xpos=${xpos}x0"
done

read -rp "Apply this layout? [y/N] " apply
if [[ ! "$apply" =~ ^[Yy]$ ]]; then
  echo "Aborted by user."
  exit 0
fi

# Apply each monitor via hyprctl keyword monitor "<name>,<res>@<hz>,<x>0,<scale>"
for name in "${ORDERED[@]}"; do
  mode=${MON_MODE[$name]}
  scale=${MON_SCALE[$name]}
  xpos=${MON_XPOS[$name]}
  hz=${MON_HZ[$name]:-60}

  # If mode == "preferred" use preferred else use the chosen <WxH@Hz>
  if [ "$mode" = "preferred" ]; then
    mode_str="preferred"
    # hyprctl keyword expects: name,preferred,xpos,scale  — but to be safe include "preferred,${xpos}x0,${scale}"
    cmd="hyprctl keyword monitor \"$name,preferred,${xpos}x0,${scale}\""
  else
    # ensure mode is like WxH@HZ (no spaces)
    res=$(awk -F'@' '{print $1}' <<<"$mode" | tr -d ' ')
    # use integer hz
    hz_i=$(awk -F'@' '{print $2}' <<<"$mode" | awk -F'.' '{print $1}')
    # construct
    cmd="hyprctl keyword monitor \"$name,${res}@${hz_i},${xpos}x0,${scale}\""
  fi

  echo "Applying: $cmd"
  # eval to allow the quotes and comma separated format
  eval "$cmd" || { echo "Failed to apply monitor $name"; }
done

echo "Reloading Hyprland configuration to pick changes up..."
hyprctl reload || true

echo "Done."


