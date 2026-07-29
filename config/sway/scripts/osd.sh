#!/usr/bin/env bash
# OSD notifications

LOCK="/tmp/sway-osd.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0   # drop overlapping/rapid-fire calls instead of racing

TAG_VOL="x-canonical-private-synchronous:volume"
TAG_MIC="x-canonical-private-synchronous:mic"
TAG_BRI="x-canonical-private-synchronous:brightness"
TAG_MEDIA="x-canonical-private-synchronous:media"
SEGMENTS=20

bar() {
    local pct=$1 filled=0 out=""
    filled=$(( pct * SEGMENTS / 100 ))
    (( filled > SEGMENTS )) && filled=$SEGMENTS
    (( filled < 0 )) && filled=0
    for (( i=0; i<SEGMENTS; i++ )); do
        if (( i < filled )); then
            out+="▰"
        else
            out+="▱"
        fi
    done
    echo "$out"
}

notify_volume() {
    local info pct
    info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$info" | grep -q MUTED; then
        notify-send -a OSD -h string:$TAG_VOL -u low "Volume" "MUTED"
    else
        pct=$(echo "$info" | grep -Po '[0-9.]+' | awk '{printf "%d", $1*100}')
        notify-send -a OSD -h string:$TAG_VOL -u low "Volume ${pct}%" "$(bar "$pct")"
    fi
}

notify_brightness() {
    local pct
    pct=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
    notify-send -a OSD -h string:$TAG_BRI -u low "Brightness ${pct}%" "$(bar "$pct")"
}

case "$1" in
    vol-up)      
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0
        notify_volume 
        ;;
    vol-down)    
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        notify_volume 
        ;;
    vol-mute)    
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        notify_volume 
        ;;
    mic-mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        state=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo MUTED || echo LIVE)
        notify-send -a OSD -h string:$TAG_MIC -u low "Mic" "$state"
        ;;
    bright-up)   
        brightnessctl set 5%+ > /dev/null
        notify_brightness 
        ;;
    bright-down) 
        brightnessctl set 5%- > /dev/null
        notify_brightness 
        ;;
    play-pause)
        playerctl play-pause
        notify-send -a OSD -h string:$TAG_MEDIA -u low "Media" "$(playerctl status)"
        ;;
    prev)
        playerctl previous
        notify-send -a OSD -h string:$TAG_MEDIA -u low "Media" "◄ $(playerctl metadata title 2>/dev/null)"
        ;;
    next)
        playerctl next
        notify-send -a OSD -h string:$TAG_MEDIA -u low "Media" "► $(playerctl metadata title 2>/dev/null)"
        ;;
    stop)
        playerctl stop
        notify-send -a OSD -h string:$TAG_MEDIA -u low "Media" "Stopped"
        ;;
    screenshot)
        file=~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
        grim "$file"
        notify-send -a OSD -u low "Screenshot" "$(basename "$file")"
        ;;
esac
