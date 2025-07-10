#!/bin/bash

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -i MUTED)

if [[ -n "$MUTED" ]]; then
  echo " muted"
else
  echo " $VOLUME%"
fi
