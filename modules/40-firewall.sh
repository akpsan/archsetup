#!/usr/bin/env bash
# desc: ufw firewall: block incoming, allow outgoing
source "$(dirname "$0")/../lib/common.sh"

pkgs ufw
if sudo ufw status | grep -q "Status: active"; then
  ok "ufw already active (rules left as they are)"
else
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw --force enable
fi
enable_now ufw
