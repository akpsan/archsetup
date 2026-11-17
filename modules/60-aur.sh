#!/usr/bin/env bash
# desc: paru AUR helper
source "$(dirname "$0")/../lib/common.sh"

if command -v paru >/dev/null; then
  ok "paru installed"
  exit 0
fi
pkgs base-devel git
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$build/paru-bin"
(cd "$build/paru-bin" && makepkg -si --noconfirm)
