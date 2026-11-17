#!/usr/bin/env bash
# desc: Timeshift snapshots, plus an automatic snapshot before each update
source "$(dirname "$0")/../lib/common.sh"

pkgs timeshift cronie
enable_now cronie            # Timeshift's scheduled snapshots run from cron
aur timeshift-autosnap       # snapshot before every pacman upgrade

if ! sudo test -s /etc/timeshift/timeshift.json; then
  warn "One-time step: open Timeshift, pick RSYNC, choose the root disk, set a schedule"
else
  ok "Timeshift already configured"
fi
