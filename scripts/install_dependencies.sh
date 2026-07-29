#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
    sway
    mako
    grim
)

echo "=> Checking dependencies..."

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
