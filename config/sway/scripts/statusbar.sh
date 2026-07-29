#!/usr/bin/env bash
# status line for swaybar: cpu | ram | net | date

IFACE=$(ip route | awk '/^default/ {print $5; exit}')

prev_rx=0
prev_tx=0
net_str=""

get_cpu() {
    read -r _ u1 n1 s1 i1 _ < /proc/stat
    total1=$((u1+n1+s1+i1))
    idle1=$i1
    sleep 0.3
    read -r _ u2 n2 s2 i2 _ < /proc/stat
    total2=$((u2+n2+s2+i2))
    idle2=$i2
    diff_total=$((total2-total1))
    diff_idle=$((idle2-idle1))
    (( diff_total == 0 )) && { echo 0; return; }
    echo $(( (100*(diff_total-diff_idle)) / diff_total ))
}

get_ram() {
    awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{
        used=(t-a)/1048576
        tot=t/1048576
        
        if (tot >= 100) {
            # 3 digits zero padding (e.g. 008.2/128.5GB)
            printf "%05.1f/%05.1fGB", used, tot
        } else if (tot >= 10) {
            # 2 digits zero padding (e.g. 08.2/16.0GB)
            printf "%04.1f/%04.1fGB", used, tot
        } else {
            # No zero padding (e.g. 4.2/8.0GB)
            printf "%.1f/%.1fGB", used, tot
        }
    }' /proc/meminfo
}

fmt_rate() {
    local bytes=$1
    awk -v b="$bytes" 'BEGIN{
        if (b < 1024) {
            str = sprintf("%dB/s", b)
        } else if (b < 1048576) {
            str = sprintf("%dKB/s", b/1024)
        } else if (b < 1073741824) {
            str = sprintf("%.1fMB/s", b/1048576)
        } else {
            str = sprintf("%.1fGB/s", b/1073741824)
        }
        printf "%10s", str
    }'
}

update_net() {
    if [[ -z "$IFACE" ]]; then
        net_str="▼$(fmt_rate 0)▲$(fmt_rate 0)"
        return
    fi
    local rx tx rx_delta tx_delta rx_fmt tx_fmt
    rx=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null || echo 0)
    tx=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null || echo 0)
    rx_delta=$(( rx - prev_rx ))
    tx_delta=$(( tx - prev_tx ))
    (( rx_delta < 0 )) && rx_delta=0
    (( tx_delta < 0 )) && tx_delta=0
    rx_fmt=$(fmt_rate "$rx_delta")
    tx_fmt=$(fmt_rate "$tx_delta")
    prev_rx=$rx
    prev_tx=$tx
    net_str="▼${rx_fmt}  ▲${tx_fmt}"
}

if [[ -n "$IFACE" ]]; then
    prev_rx=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null || echo 0)
    prev_tx=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null || echo 0)
fi

while true; do
    cpu=$(get_cpu)
    ram=$(get_ram)
    update_net
    dt=$(date +'%Y-%m-%d %H:%M:%S')

    printf " %3d%%  |  %s  |  %s  |  %s  \n" "$cpu" "$ram" "$net_str" "$dt"

    sleep 0.7
done
