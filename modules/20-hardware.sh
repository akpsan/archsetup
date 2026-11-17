#!/usr/bin/env bash
# desc: CPU microcode and GPU drivers, detected from the hardware
source "$(dirname "$0")/../lib/common.sh"

log "CPU microcode"
case $(grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}') in
  AuthenticAMD) ucode=amd-ucode ;;
  GenuineIntel) ucode=intel-ucode ;;
  *) ucode="" ; warn "Unknown CPU vendor; skipping microcode" ;;
esac
if [[ -n $ucode ]] && ! is_installed "$ucode"; then
  pkgs "$ucode"
  if [[ -f /boot/grub/grub.cfg ]]; then
    log "Regenerating GRUB config to load microcode"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    warn "Add /$ucode.img to your bootloader entry manually"
  fi
elif [[ -n $ucode ]]; then
  ok "$ucode installed"
fi

log "GPU drivers"
gpus=$(lspci -nn | grep -iE 'vga|3d|display' || true)
grep -qi 'amd\|ati'  <<<"$gpus" && pkgs mesa vulkan-radeon libva-mesa-driver
grep -qi 'intel'     <<<"$gpus" && pkgs mesa vulkan-intel intel-media-driver
if grep -qi 'nvidia' <<<"$gpus"; then
  warn "NVIDIA GPU found: install drivers by hand (nvidia-open or nvidia), see the Arch wiki"
fi
ok "${gpus:-no GPU detected}"
