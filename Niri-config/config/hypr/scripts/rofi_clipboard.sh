#!/usr/bin/env bash
# Clipboard picker using cliphist + rofi

cliphist list | rofi -dmenu -theme ~/.config/rofi/theme.rasi | cliphist decode | wl-copy
