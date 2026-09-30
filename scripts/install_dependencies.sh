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
    zsh
    fzf
    bat
    eza
    duf
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

echo "=> Setting up Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Force ZSH variable to the local home directory during installation
    ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    # Hardcode the local path for plugins to prevent ZSH_CUSTOM variable pollution
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
    echo "   Oh My Zsh already installed."
fi

# Change default shell for user
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    sudo chsh -s /usr/bin/zsh "$USER"
fi

echo "=> Setting Qt Platform Theme in /etc/environment..."
if ! grep -q "QT_QPA_PLATFORMTHEME=qt6ct" /etc/environment; then
    echo "QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment > /dev/null
    echo "   Added QT_QPA_PLATFORMTHEME=qt6ct"
else
    echo "   Qt Platform Theme already set."
fi

echo "=> Setting KDE default terminal to kitty..."
if command -v kwriteconfig6 &> /dev/null; then
    kwriteconfig6 --file kdeglobals --group General --key TerminalApplication "kitty"
    echo "   Set TerminalApplication=kitty in kdeglobals"
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
