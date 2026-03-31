# Arch Linux Dotfiles (ilyamiro NixOS port)

Arch Linux equivalent of [ilyamiro's NixOS configuration](https://github.com/ilyamiro/nixos-configuration).

## Stack

| Component | Package |
|-----------|---------|
| Window Manager | **Hyprland** |
| Display Manager | **GDM** (or SDDM) |
| Terminal | **Kitty** |
| Shell | **Zsh** |
| App Launcher | **Rofi (Wayland)** |
| Notifications | **SwayNC** |
| Wallpaper | **swww** |
| Audio | **PipeWire + EasyEffects** |
| Lock screen | **hyprlock / quickshell** |
| Idle daemon | **hypridle** |
| Volume OSD | **SwayOSD** |
| Audio visualizer | **cava** |
| Theme | **adw-gtk3-dark + Catppuccin Mocha palette** |
| Cursors | **ArcMidnight-Cursors** |
| Fonts | **JetBrains Mono Nerd + Noto** |
| QT theme | **qt6ct → Fusion** |

## Install

> ⚠️ Run **only on a fresh Arch Linux install** as root. Backup existing dotfiles first.

```bash
git clone https://github.com/yourname/arch-dotfiles ~/.dotfiles
cd ~/.dotfiles
sudo bash install.sh
```

After install, **reboot** and select **Hyprland** on GDM.

## File structure

```
.
├── install.sh                  # Main install script
└── config/
    ├── hypr/
    │   ├── hyprland.conf       # Main Hyprland config
    │   ├── animations.conf     # Window/workspace animations
    │   ├── binds.conf          # Keybinds (SUPER key)
    │   ├── monitors.conf       # Monitor setup (edit for your hardware)
    │   ├── window-rules.conf   # Float / pin rules
    │   ├── autostart.conf      # exec-once startup programs
    │   ├── hypridle.conf       # Idle → lock → suspend
    │   └── scripts/            # Helper shell scripts
    │       ├── screenshot.sh
    │       ├── lock.sh
    │       ├── rofi_show.sh
    │       ├── rofi_clipboard.sh
    │       └── volume_listener.sh
    ├── kitty/
    │   └── kitty.conf          # JetBrains Mono, bg opacity 0.85
    ├── rofi/
    │   ├── config.rasi         # Modi + mouse config
    │   └── theme.rasi          # Catppuccin glassmorphism theme
    ├── cava/
    │   └── config              # PipeWire input, gradient colors
    ├── zsh/
    │   └── .zshrc              # Aliases, cd→ls, qcopy, fetch
    ├── qt6ct/
    │   └── qt6ct.conf          # Qt Fusion dark
    └── fonts/                  # Custom local fonts (optional)
```

## Keybinds

| Keys | Action |
|------|--------|
| `SUPER + RETURN` | Open Kitty |
| `SUPER + D` | App launcher (Rofi drun) |
| `ALT + TAB` | Window switcher (Rofi) |
| `SUPER + C` | Clipboard picker |
| `SUPER + L` | Lock screen |
| `SUPER + F` | Firefox |
| `SUPER + E` | Nautilus |
| `SUPER + T` | Telegram |
| `SUPER + A` | Toggle SwayNC |
| `SUPER + [1-9]` | Switch workspace |
| `SUPER + SHIFT + [1-9]` | Move window to workspace |
| `SUPER + arrows` | Move focus |
| `SUPER + CTRL + arrows` | Move window |
| `SUPER + SHIFT + arrows` | Resize window |
| `ALT + F4` | Close window |
| `Print` | Screenshot region |
| `SHIFT + Print` | Screenshot + edit (satty) |
| `SUPER + SPACE` | Play/pause media |

## Customisation

### Monitor
Edit `config/hypr/monitors.conf`:
```
monitor = eDP-1, 1920x1080@60, 0x0, 1
```

### Hostname / Timezone
Edit `install.sh` and change:
- `echo "ilyamiro"` → your username
- `Europe/Copenhagen` → your timezone

### GTK Theme
The installer applies `adw-gtk3-dark`. Install `adw-gtk3` from AUR separately if not available.

## Notes

- **Quickshell** widgets (TopBar, Main, Lock) are **not included** — you need to supply your own or port them separately. The scripts reference `~/.config/hypr/scripts/quickshell/`.
- The `matugen` dynamic color system works on Arch — install `matugen-bin` from the AUR.
- `swayosd` requires the `swayosd-libinput-backend.service` user service to be running.
