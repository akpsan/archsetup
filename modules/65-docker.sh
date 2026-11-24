#!/usr/bin/env bash
# desc: Docker engine, compose and buildx; adds you to the docker group
source "$(dirname "$0")/../lib/common.sh"

pkgs docker docker-compose docker-buildx
enable_now docker.service

# id reads /etc/group, so this sees the change even before you log in again.
if id -nG "$USER" | grep -qw docker; then
  ok "$USER already in docker group"
else
  sudo usermod -aG docker "$USER"
  ok "added $USER to docker group"
  needs_reboot "join the docker group (logging out and back in is enough)"
fi
