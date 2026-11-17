#!/usr/bin/env bash
# desc: Bluetooth stack and tray applet (skipped if no adapter)
source "$(dirname "$0")/../lib/common.sh"

if ! compgen -G "/sys/class/bluetooth/hci*" >/dev/null; then
  ok "No Bluetooth adapter; skipping"
  exit 0
fi
pkgs bluez bluez-utils blueman
enable_now bluetooth
