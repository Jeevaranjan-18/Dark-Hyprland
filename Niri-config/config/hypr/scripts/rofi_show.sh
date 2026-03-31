#!/usr/bin/env bash
# Rofi launcher wrapper

MODE="${1:-drun}"
rofi -show "$MODE" -theme ~/.config/rofi/theme.rasi
