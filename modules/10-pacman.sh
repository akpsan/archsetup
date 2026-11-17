#!/usr/bin/env bash
# desc: pacman tweaks, fast mirrors (reflector), cache cleanup, full system update
source "$(dirname "$0")/../lib/common.sh"
require MIRROR_COUNTRIES

log "pacman.conf"
set_conf /etc/pacman.conf Color ""
set_conf /etc/pacman.conf ParallelDownloads 10

log "Mirrors"
pkgs reflector pacman-contrib
if {
  echo "--save /etc/pacman.d/mirrorlist"
  echo "--protocol https"
  [[ -n $MIRROR_COUNTRIES ]] && echo "--country $MIRROR_COUNTRIES"
  echo "--latest 10"
  echo "--sort rate"
} | write_root /etc/xdg/reflector/reflector.conf
then
  log "Ranking mirrors (one-off, then weekly via timer)"
  sudo systemctl start reflector.service || warn "reflector failed; keeping current mirrorlist"
fi
enable_now reflector.timer paccache.timer

log "System update"
sudo pacman -Syu --noconfirm
