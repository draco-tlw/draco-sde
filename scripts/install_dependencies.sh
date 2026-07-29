#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
    sway
    mako
    grim
    rofi
)

echo "=> Checking dependencies..."

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
