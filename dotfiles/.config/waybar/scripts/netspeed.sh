#!/usr/bin/env bash
# Waybar custom module: shows whichever of download/upload is currently higher.
# Emits one JSON line every $INTERVAL seconds.
INTERVAL=2
DOWN=$'\U000f01da'   # 󰇚
UP=$'\U000f0552'     # 󰕒
OFF=$'\U000f05aa'    # 󰖪

human() {  # bytes/s -> "12.3 MB/s"
  awk -v b="$1" 'BEGIN {
    split("B KB MB GB", u); i = 1
    while (b >= 1024 && i < 4) { b /= 1024; i++ }
    printf (i == 1 ? "%d %s/s" : "%.1f %s/s"), b, u[i] }'
}

prev_if= prev_rx=0 prev_tx=0
while :; do
  iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
  if [[ -z $iface || ! -r /sys/class/net/$iface/statistics/rx_bytes ]]; then
    printf '{"text":"%s  offline","class":"disconnected","tooltip":"No network"}\n' "$OFF"
    prev_if=; sleep "$INTERVAL"; continue
  fi
  rx=$(<"/sys/class/net/$iface/statistics/rx_bytes")
  tx=$(<"/sys/class/net/$iface/statistics/tx_bytes")
  if [[ $iface == "$prev_if" ]]; then
    down=$(( (rx - prev_rx) / INTERVAL )); up=$(( (tx - prev_tx) / INTERVAL ))
  else
    down=0; up=0   # first sample or interface changed
  fi
  prev_if=$iface prev_rx=$rx prev_tx=$tx

  if (( up > down )); then text="$UP  $(human "$up")"; class=up
  else                     text="$DOWN  $(human "$down")"; class=down; fi
  printf '{"text":"%s","class":"%s","tooltip":"%s\\n%s  %s\\n%s  %s"}\n' \
    "$text" "$class" "$iface" "$DOWN" "$(human "$down")" "$UP" "$(human "$up")"
  sleep "$INTERVAL"
done
