#!/usr/bin/env bash
# Screenshot helper - equivalent to NixOS hyprshot wrapper

if [[ "$1" == "--edit" ]]; then
    hyprshot -m region --clipboard-only | satty --filename -
else
    hyprshot -m region -o ~/Pictures/Screenshots/
fi
