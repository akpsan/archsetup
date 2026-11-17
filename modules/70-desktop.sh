#!/usr/bin/env bash
# desc: Hyprland desktop, audio, fonts, apps, user folders
source "$(dirname "$0")/../lib/common.sh"

log "Hyprland and Wayland plumbing"
is_installed hyprland || needs_reboot "Hyprland desktop installed"
pkgs hyprland hyprlauncher hyprpaper hyprpolkitagent hyprlock hypridle \
     xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils \
     qt5-wayland qt6-wayland waybar mako wofi \
     wl-clipboard cliphist grim slurp wf-recorder \
     python  # python: window picking in ~/.local/bin/screenshot and screenrecord

log "Audio"
pkgs pipewire pipewire-pulse wireplumber pavucontrol playerctl
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service \
  || warn "Could not start user audio services (fine outside a login session)"

log "Fonts"
pkgs ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk terminus-font

log "Apps"
pkgs kitty dolphin gvfs firefox

log "User folders"
pkgs xdg-user-dirs
xdg-user-dirs-update
