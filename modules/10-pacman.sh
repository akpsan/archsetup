#!/usr/bin/env bash
# desc: pacman tweaks, fast mirrors (reflector), cache cleanup, keep running kernel's modules, full system update
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

# A kernel upgrade deletes the running kernel's modules, so anything that loads
# a module before the next reboot fails (docker needs the nat netfilter modules).
# kernel-modules-hook keeps them until reboot; its cleanup service drops the
# old copies at boot. Installed before the update so it covers this one too.
log "Keep running kernel's modules across upgrades"
pkgs kernel-modules-hook
sudo systemctl enable linux-modules-cleanup.service

log "System update"
sudo pacman -Syu --noconfirm
