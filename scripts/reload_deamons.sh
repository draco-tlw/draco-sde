echo "=> Reloading daemons..."

if pgrep -x "sway" > /dev/null; then
    swaymsg reload || echo "Sway reload failed."
fi

if pgrep -x "noctalia" > /dev/null; then
    noctalia msg config-reload || echo "Noctalia reload failed."
else
    echo "Noctalia is not running, starting it..."
    noctalia &
    disown
fi

echo "=> Reload complete."
