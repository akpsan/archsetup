#!/usr/bin/env bash
# desc: core tools, zram swap, time sync, SSD trim
source "$(dirname "$0")/../lib/common.sh"

log "Core tools"
pkgs base-devel git vim man-db man-pages unzip zip ntfs-3g networkmanager

log "zram swap ($ZRAM_SIZE)"
pkgs zram-generator
if write_root /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = $ZRAM_SIZE
compression-algorithm = zstd
EOF
then
  sudo systemctl daemon-reload
  sudo systemctl restart systemd-zram-setup@zram0.service
fi

log "Console font (readable on high-resolution screens)"
pkgs terminus-font
sudo touch /etc/vconsole.conf
if ! sudo grep -qxF 'FONT=ter-132b' /etc/vconsole.conf; then
  if sudo grep -q '^FONT=' /etc/vconsole.conf; then
    sudo sed -i 's/^FONT=.*/FONT=ter-132b/' /etc/vconsole.conf
  else
    echo 'FONT=ter-132b' | sudo tee -a /etc/vconsole.conf >/dev/null
  fi
  ok "/etc/vconsole.conf: FONT=ter-132b"
else
  ok "/etc/vconsole.conf unchanged"
fi

log "Services"
enable_now NetworkManager systemd-timesyncd fstrim.timer
