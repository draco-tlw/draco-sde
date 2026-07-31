#!/usr/bin/env bash
set -euo pipefail

PACMAN_PACKAGES=(
    sway
    swaybg
    swayidle
    swaylock
    kitty
    mako
    grim
    rofi
    bluetui
    wiremix
    polkit-kde-agent
    polkit-gnome
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
)

AUR_PACKAGES=(
    wifitui
    clipse
)

echo "=> Checking dependencies..."

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

paru -S --needed "${AUR_PACKAGES[@]}"
