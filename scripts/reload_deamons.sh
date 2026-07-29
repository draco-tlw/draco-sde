echo "=> Reloading daemons..."

if pgrep -x "sway" > /dev/null; then
    swaymsg reload || echo "Sway reload failed, is it running under this TTY?"
else
    echo "Sway is not running, skipping sway reload."
fi

if pgrep -x "mako" > /dev/null; then
    makoctl reload || echo "Mako reload failed."
else
    echo "Mako is not running, starting it..."
    mako &
    disown
fi

echo "=> Reload complete."
