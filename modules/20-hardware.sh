#!/usr/bin/env bash
# desc: CPU microcode and GPU drivers, detected from the hardware
source "$(dirname "$0")/../lib/common.sh"

log "CPU microcode"
case $(grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}') in
  AuthenticAMD) ucode=amd-ucode ;;
  GenuineIntel) ucode=intel-ucode ;;
  *) ucode="" ; warn "Unknown CPU vendor; skipping microcode" ;;
esac
if [[ -n $ucode ]]; then
  if is_installed "$ucode"; then
    ok "$ucode installed"
  else
    pkgs "$ucode"
    fresh_ucode=1
    needs_reboot "CPU microcode installed"
  fi

  # Only GRUB is wired up automatically; anything else is left alone.
  if sudo test -f /boot/grub/grub.cfg; then
    if [[ -n ${fresh_ucode:-} ]]; then
      log "Regenerating GRUB config to load microcode"
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
  else
    warn "Bootloader isn't GRUB: skipped microcode boot setup. Add /$ucode.img to your boot entry yourself"
  fi
fi

log "GPU drivers"
gpus=$(lspci -nn | grep -iE 'vga|3d|display' || true)
grep -qi 'amd\|ati'  <<<"$gpus" && pkgs mesa vulkan-radeon libva-mesa-driver
grep -qi 'intel'     <<<"$gpus" && pkgs mesa vulkan-intel intel-media-driver
ok "${gpus:-no GPU detected}"
