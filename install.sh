#!/usr/bin/env bash
set -euo pipefail

./scripts/install_dependencies.sh
./scripts/link_configs.sh
./scripts/reload_deamons.sh

echo "=> Applying KDE/Dolphin color scheme settings..."
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "noctalia"
kwriteconfig6 --file ~/.config/dolphinrc --group UiSettings --key ColorScheme "noctalia"

echo "=> Installation complete."
