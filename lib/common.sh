#!/usr/bin/env bash
# Shared helpers for every module. Source it; don't run it.
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_DIR="$REPO_DIR/dotfiles"

LOCAL_CONF="$REPO_DIR/settings.local.conf"

# shellcheck source=../settings.conf
source "$REPO_DIR/settings.conf"
[[ -f $LOCAL_CONF ]] && source "$LOCAL_CONF"

log()  { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
ok()   { printf '\e[1;32m  ✓\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m  !\e[0m %s\n' "$*" >&2; }
die()  { printf '\e[1;31m  ✗\e[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "Run as your normal user. sudo is used only where needed."

# Personal settings are never stored in the repo. `require VAR...` asks for
# any that aren't set yet and saves the answers to settings.local.conf
# (gitignored), so each is asked only once per machine.
declare -A PROMPTS=(
  [GIT_NAME]="Git user name"
  [GIT_EMAIL]="Git email"
  [MIRROR_COUNTRIES]="Mirror countries, comma-separated (e.g. Germany,France; blank = worldwide)"
)
declare -A ALLOW_BLANK=([MIRROR_COUNTRIES]=1)
declare -A SUGGEST=(
  [GIT_NAME]="$(git config --global user.name 2>/dev/null || true)"
  [GIT_EMAIL]="$(git config --global user.email 2>/dev/null || true)"
)

require() {
  local var answer hint
  for var in "$@"; do
    [[ -n ${!var+x} ]] && continue                     # already set (even if blank)
    [[ -t 0 ]] || die "$var is not set. Run interactively or add it to $LOCAL_CONF"
    hint=${SUGGEST[$var]:-}
    while :; do
      read -rp "  ? ${PROMPTS[$var]:-$var}${hint:+ [$hint]}: " answer
      answer=${answer:-$hint}
      [[ -n $answer || -n ${ALLOW_BLANK[$var]:-} ]] && break
      warn "required"
    done
    printf '%s=%q\n' "$var" "$answer" >> "$LOCAL_CONF"
    printf -v "$var" '%s' "$answer"
  done
}

# Install official packages (already-installed ones are skipped).
pkgs() { sudo pacman -S --needed --noconfirm "$@"; }

# Install AUR packages via paru.
aur() {
  command -v paru >/dev/null || die "paru not found; run the 'aur' module first"
  paru -S --needed --noconfirm "$@"
}

# needs_reboot REASON
# Notes that a change only takes effect after a reboot. install.sh collects
# these and offers to reboot at the end; a module run on its own just says so.
needs_reboot() {
  if [[ -n ${REBOOT_FILE:-} ]]; then
    grep -qxF "$1" "$REBOOT_FILE" 2>/dev/null || echo "$1" >> "$REBOOT_FILE"
  else
    warn "Reboot needed: $1"
  fi
}

is_installed() { pacman -Qq "$1" &>/dev/null; }

# Enable and start systemd units (no-op if already enabled and running).
enable_now() { sudo systemctl enable --now "$@"; }

# write_root DEST < content
# Writes a root-owned file only if its content differs.
# Returns 0 when the file changed, 1 when it was already up to date.
write_root() {
  local dst=$1 tmp
  tmp=$(mktemp); cat > "$tmp"
  if sudo test -f "$dst" && sudo cmp -s "$tmp" "$dst"; then
    rm -f "$tmp"; ok "$dst unchanged"; return 1
  fi
  sudo install -Dm644 "$tmp" "$dst"; rm -f "$tmp"
  ok "wrote $dst"; return 0
}

# set_conf FILE KEY VALUE
# Ensures "KEY = VALUE" in an INI-style file such as pacman.conf,
# uncommenting or replacing an existing line, else appending to [options].
set_conf() {
  local file=$1 key=$2 val=$3 line
  line="$key${val:+ = $val}"
  if sudo grep -qxF "$line" "$file"; then return 0; fi
  if sudo grep -qE "^#?\s*$key(\s|=|$)" "$file"; then
    sudo sed -i -E "0,/^#?\s*$key(\s|=|$).*/s//$line/" "$file"
  else
    sudo sed -i "/^\[options\]/a $line" "$file"
  fi
  ok "$file: $line"
}
