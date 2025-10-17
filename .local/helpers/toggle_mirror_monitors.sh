#!/bin/bash

MIRRORED=$(hyprctl monitors all -j | jq -r '.[] | select(.mirrorOf != "none") | .name')

if [ -n "$MIRRORED" ]; then
  echo "Detected mirrored monitors: $MIRRORED"
  for MON in $MIRRORED; do
    echo "Restoring $MON..." 
    hyprctl keyword monitor "$MON,preferred,auto,1"
  done
  echo "Mirroring removed."
else
  echo "No mirrored monitors detected."
fi

