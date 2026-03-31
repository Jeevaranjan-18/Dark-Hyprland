#!/usr/bin/env bash
# Lock screen script

quickshell -p ~/.config/hypr/scripts/quickshell/Lock.qml 2>/dev/null || \
    hyprlock
