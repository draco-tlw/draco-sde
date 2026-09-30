#!/usr/bin/env bash
set -euo pipefail

echo "=> Disabling existing display managers..."
for dm in sddm gdm lightdm lxdm slim; do
    if systemctl is-enabled --quiet "$dm" 2>/dev/null || systemctl is-active --quiet "$dm" 2>/dev/null; then
        sudo systemctl disable --now "$dm" || true
        echo "   Disabled $dm."
    fi
done

echo "=> Configuring greeter permissions..."
sudo useradd -M -G video greeter 2>/dev/null || true

echo "=> Writing greetd configuration..."
sudo mkdir -p /etc/greetd
cat <<EOF | sudo tee /etc/greetd/config.toml > /dev/null
[terminal]
vt = 1

[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "greeter"
EOF

echo "=> Enabling greetd..."
sudo systemctl enable greetd.service

echo "=> Setup complete. Rebooting in 5 seconds... (Press Ctrl+C to cancel)"
sleep 5
sudo systemctl reboot
