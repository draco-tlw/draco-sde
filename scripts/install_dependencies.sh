#!/usr/bin/env bash
set -euo pipefail

PACMAN_PACKAGES=(
    sway
    kitty
    grim
    bluetui
    wiremix
    polkit-kde-agent
    polkit-gnome
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    fastfetch
    noctalia
    breeze
    adw-gtk-theme
    ddcutil
    noctalia-greeter
)

AUR_PACKAGES=(
    wifitui
    clipse
    qt5ct-kde
    qt6ct-kde
)

echo "=> Checking dependencies..."

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

paru -S --needed "${AUR_PACKAGES[@]}"

echo "=> Setting Qt Platform Theme in /etc/environment..."
if ! grep -q "QT_QPA_PLATFORMTHEME=qt6ct" /etc/environment; then
    echo "QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment > /dev/null
    echo "   Added QT_QPA_PLATFORMTHEME=qt6ct"
else
    echo "   Qt Platform Theme already set."
fi

echo "=> Configuring i2c permissions for ddcutil..."
# Automatically load the i2c-dev module on boot
if [ ! -f /etc/modules-load.d/i2c-dev.conf ] || ! grep -q "i2c-dev" /etc/modules-load.d/i2c-dev.conf; then
    echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf > /dev/null
    echo "   Added i2c-dev to modules-load.d"
fi

# Load the module immediately so it works without rebooting
sudo modprobe i2c-dev || true

# Add the current user to the i2c group
sudo usermod -aG i2c "$USER"
echo "   Added $USER to i2c group."
