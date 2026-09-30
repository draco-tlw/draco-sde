#!/bin/bash
if [ "$NOCTALIA_THEME_MODE" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi
