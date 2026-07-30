#!/usr/bin/env bash
set -euo pipefail

PACMAN_PACKAGES=(
    sway
    mako
    grim
    rofi
    bluetui
    wiremix
)

AUR_PACKAGES=(
    wifitui
    clipse
)

echo "=> Checking dependencies..."

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

paru -S --needed "${AUR_PACKAGES[@]}"
