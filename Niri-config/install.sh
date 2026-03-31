#!/usr/bin/env bash
# =============================================================================
# Arch Linux Dotfiles Installer
# Clone of ilyamiro's NixOS configuration — ported for Arch Linux
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="/home/$USER_NAME"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

need_root() {
  [[ $EUID -ne 0 ]] && error "Please run as root: sudo bash install.sh"
}

# ─────────────────────────────────────────────────────────────
# 1. SYSTEM UPDATE & BASE TOOLS
# ─────────────────────────────────────────────────────────────
install_base() {
  info "Updating system and installing base tools..."
  pacman -Syu --noconfirm
  pacman -S --noconfirm --needed \
    base-devel git curl wget \
    zsh fzf direnv neovim \
    btop fastfetch tree jq socat bc \
    python python-pip \
    ffmpeg p7zip \
    imagemagick \
    ripgrep fd \
    killall inetutils
  success "Base tools installed."
}

# ─────────────────────────────────────────────────────────────
# 2. AUR HELPER (yay)
# ─────────────────────────────────────────────────────────────
install_yay() {
  if command -v yay &>/dev/null; then
    info "yay already installed, skipping."
    return
  fi
  info "Installing yay (AUR helper)..."
  sudo -u "$USER_NAME" bash -c "
    cd /tmp
    rm -rf yay-bin
    git clone https://aur.archlinux.org/yay-bin.git yay-bin
    cd yay-bin
    makepkg -si --noconfirm
  "
  success "yay installed."
}

# ─────────────────────────────────────────────────────────────
# 3. PACMAN PACKAGES
# ─────────────────────────────────────────────────────────────
install_pacman_packages() {
  info "Installing pacman packages..."
  pacman -S --noconfirm --needed \
    hyprland hyprlock hypridle hyprpicker \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt6-base qt6-multimedia qt6-5compat \
    gtk3 gtk4 \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack \
    wireplumber \
    bluez bluez-utils blueman \
    networkmanager network-manager-applet \
    cups \
    openssh \
    power-profiles-daemon \
    flatpak \
    rofi-wayland \
    kitty \
    wl-clipboard cliphist \
    swww \
    swaync \
    playerctl \
    grim slurp satty swappy \
    pavucontrol \
    alsa-utils pamixer brightnessctl \
    libnotify \
    acpi \
    iw \
    lm_sensors \
    qt6ct \
    adwaita-icon-theme \
    gnome-themes-extra \
    gnome-keyring \
    nautilus \
    libreoffice-fresh \
    hunspell hunspell-ru hunspell-en_us \
    obsidian \
    obs-studio \
    qbittorrent \
    telegram-desktop \
    firefox \
    steam \
    gamemode \
    jdk8-openjdk \
    wine \
    taskwarrior \
    mpv \
    fortune-mod \
    cava \
    dconf \
    plymouth \
    ladspa \
    wmctrl \
    matugen
  success "Pacman packages installed."
}

# ─────────────────────────────────────────────────────────────
# 4. AUR PACKAGES
# ─────────────────────────────────────────────────────────────
install_aur_packages() {
  info "Installing AUR packages..."
  sudo -u "$USER_NAME" yay -S --noconfirm --needed \
    swayosd-git \
    adw-gtk3 \
    easyeffects \
    hyprshot \
    networkmanager-dmenu-git \
    quickshell-git \
    bottles \
    mpvpaper \
    papers-git \
    udev-gothic-nf \
    matugen-bin \
    ladspa-sdk
  success "AUR packages installed."
}

# ─────────────────────────────────────────────────────────────
# 5. FONTS
# ─────────────────────────────────────────────────────────────
install_fonts() {
  info "Installing fonts..."
  pacman -S --noconfirm --needed \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    ttf-liberation \
    ttf-jetbrains-mono-nerd

  # ArcMidnight cursors
  local cursor_dir="$USER_HOME/.local/share/icons/ArcMidnight-Cursors"
  if [[ ! -d "$cursor_dir" ]]; then
    info "Downloading ArcMidnight cursors..."
    sudo -u "$USER_NAME" bash -c "
      cd /tmp
      curl -L -o ArcMidnight.zip \
        'https://github.com/yeyushengfan258/ArcMidnight-Cursors/archive/refs/heads/main.zip'
      unzip -q ArcMidnight.zip
      mkdir -p '$cursor_dir'
      cp -r ArcMidnight-Cursors-main/dist/* '$cursor_dir/'
      rm -rf ArcMidnight.zip ArcMidnight-Cursors-main
    "
    success "ArcMidnight cursors installed."
  else
    info "ArcMidnight cursors already present."
  fi

  # Copy local fonts from repo
  if [[ -d "$DOTFILES_DIR/config/fonts" ]]; then
    info "Copying local fonts..."
    sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.local/share/fonts/"
    cp -r "$DOTFILES_DIR/config/fonts/." "$USER_HOME/.local/share/fonts/"
    sudo -u "$USER_NAME" fc-cache -fv &>/dev/null
    success "Local fonts copied."
  fi
}

# ─────────────────────────────────────────────────────────────
# 6. SERVICES
# ─────────────────────────────────────────────────────────────
enable_services() {
  info "Enabling system services..."
  systemctl enable --now NetworkManager
  systemctl enable --now bluetooth
  systemctl enable --now cups
  systemctl enable --now sshd
  systemctl enable --now power-profiles-daemon
  systemctl enable --now flatpak
  # Plymouth
  systemctl enable plymouth-quit-wait.service 2>/dev/null || true

  # User services
  sudo -u "$USER_NAME" systemctl --user enable --now pipewire pipewire-pulse wireplumber easyeffects 2>/dev/null || true
  sudo -u "$USER_NAME" systemctl --user enable --now swayosd-libinput-backend 2>/dev/null || true
  success "Services enabled."
}

# ─────────────────────────────────────────────────────────────
# 7. USER SETUP
# ─────────────────────────────────────────────────────────────
setup_user() {
  info "Configuring user $USER_NAME..."

  # Groups
  usermod -aG networkmanager,video,storage,audio,wheel,adbusers "$USER_NAME" 2>/dev/null || true

  # Default shell → zsh
  chsh -s "$(which zsh)" "$USER_NAME"

  # Passwordless sudo (mirrors NixOS NOPASSWD)
  if ! grep -q "^$USER_NAME ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi

  # Prevent lid-close / power-key from suspending (matches NixOS HandlePowerKey = ignore)
  sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=ignore/' /etc/systemd/logind.conf
  sed -i 's/HandlePowerKey=poweroff/HandlePowerKey=ignore/' /etc/systemd/logind.conf

  success "User configured."
}

# ─────────────────────────────────────────────────────────────
# 8. DOTFILES DEPLOYMENT
# ─────────────────────────────────────────────────────────────
deploy_dotfiles() {
  info "Deploying dotfiles..."

  mkdir -p "$USER_HOME/.config"

  # Hyprland
  mkdir -p "$USER_HOME/.config/hypr"
  cp -r "$DOTFILES_DIR/config/hypr/." "$USER_HOME/.config/hypr/"

  # Kitty
  mkdir -p "$USER_HOME/.config/kitty"
  cp -r "$DOTFILES_DIR/config/kitty/." "$USER_HOME/.config/kitty/"

  # Rofi
  mkdir -p "$USER_HOME/.config/rofi"
  cp -r "$DOTFILES_DIR/config/rofi/." "$USER_HOME/.config/rofi/"

  # SwayNC
  mkdir -p "$USER_HOME/.config/swaync"
  cp -r "$DOTFILES_DIR/config/swaync/." "$USER_HOME/.config/swaync/"

  # Zsh
  cp -f "$DOTFILES_DIR/config/zsh/.zshrc" "$USER_HOME/.zshrc"

  # Cava
  mkdir -p "$USER_HOME/.config/cava"
  cp -r "$DOTFILES_DIR/config/cava/." "$USER_HOME/.config/cava/"

  # qt6ct
  mkdir -p "$USER_HOME/.config/qt6ct"
  cp -r "$DOTFILES_DIR/config/qt6ct/." "$USER_HOME/.config/qt6ct/"

  # Fix ownership
  chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config"
  chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.zshrc" 2>/dev/null || true

  # Make scripts executable
  find "$USER_HOME/.config/hypr/scripts" -name "*.sh" -o -name "*.py" 2>/dev/null | \
    xargs chmod +x 2>/dev/null || true

  success "Dotfiles deployed."
}

# ─────────────────────────────────────────────────────────────
# 9. GTK / QT THEMING
# ─────────────────────────────────────────────────────────────
setup_theming() {
  info "Applying GTK and QT theming..."

  sudo -u "$USER_NAME" bash -c "
    # GTK3
    mkdir -p '$USER_HOME/.config/gtk-3.0'
    cat > '$USER_HOME/.config/gtk-3.0/settings.ini' <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=Adwaita
gtk-cursor-theme-name=ArcMidnight-Cursors
gtk-cursor-theme-size=24
gtk-font-name=Noto Sans 11
EOF

    # GTK4
    mkdir -p '$USER_HOME/.config/gtk-4.0'
    cat > '$USER_HOME/.config/gtk-4.0/settings.ini' <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-icon-theme-name=Adwaita
gtk-cursor-theme-name=ArcMidnight-Cursors
gtk-cursor-theme-size=24
gtk-font-name=Noto Sans 11
EOF

    # dconf (color-scheme + cursor)
    dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\"
    dconf write /org/gnome/desktop/interface/gtk-theme \"'adw-gtk3-dark'\"
    dconf write /org/gnome/desktop/interface/cursor-theme \"'ArcMidnight-Cursors'\"
    dconf write /org/gnome/desktop/interface/cursor-size 24
  "
  success "Theming applied."
}

# ─────────────────────────────────────────────────────────────
# 10. LOCALE & TIMEZONE
# ─────────────────────────────────────────────────────────────
setup_locale() {
  info "Setting locale and timezone..."

  # Uncomment en_US.UTF-8 in locale.gen
  sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
  sed -i 's/^#ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen
  locale-gen

  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime
  hwclock --systohc

  # Hostname
  echo "ilyamiro" > /etc/hostname

  # XKB (keyboard layout us,ru)
  localectl set-keymap us
  localectl set-x11-keymap "us,ru" "" "" ""

  success "Locale and timezone set."
}

# ─────────────────────────────────────────────────────────────
# 11. BOOTLOADER — Plymouth splash (optional)
# ─────────────────────────────────────────────────────────────
setup_plymouth() {
  if ! command -v plymouth &>/dev/null; then
    warn "Plymouth not found, skipping."
    return
  fi
  info "Configuring Plymouth boot splash..."

  # Add plymouth to mkinitcpio
  if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    sed -i 's/^HOOKS=(\(.*\)udev\(.*\))/HOOKS=(\1udev plymouth\2)/' /etc/mkinitcpio.conf
    mkinitcpio -P
  fi

  local theme_src="$DOTFILES_DIR/config/plymouth"
  if [[ -d "$theme_src" ]]; then
    cp -r "$theme_src/." /usr/share/plymouth/themes/
    local theme_name
    theme_name=$(ls "$theme_src" | head -1)
    [[ -n "$theme_name" ]] && plymouth-set-default-theme -R "$theme_name" || true
  fi
  success "Plymouth configured."
}

# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────
main() {
  need_root
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  Arch Linux Dotfiles — ilyamiro clone     ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  install_base
  install_yay
  install_pacman_packages
  install_aur_packages
  install_fonts
  setup_user
  setup_locale
  deploy_dotfiles
  setup_theming
  enable_services
  setup_plymouth

  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  Installation complete! Please reboot.    ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${CYAN}Reboot with:${NC} sudo reboot"
}

main "$@"
