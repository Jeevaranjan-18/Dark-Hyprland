#!/usr/bin/env bash
# Volume listener using PipeWire / pactl
# Triggers swayosd on volume changes

pactl subscribe 2>/dev/null | while read -r event; do
    if echo "$event" | grep -q "change.*sink"; then
        swayosd-client --output-volume get 2>/dev/null || true
    fi
done
