#!/usr/bin/env bash
# Run setup modules in order. Every module is safe to rerun.
#
#   ./install.sh              run every module
#   ./install.sh dotfiles git run only these (number prefix optional)
#   ./install.sh --list       show modules
set -euo pipefail
cd "$(dirname "$0")"

mapfile -t ALL < <(ls modules/*.sh | sort)

describe() { sed -n 's/^# desc: //p' "$1"; }
name_of()  { basename "$1" .sh | sed 's/^[0-9]*-//'; }

if [[ ${1:-} == --list || ${1:-} == -l ]]; then
  for m in "${ALL[@]}"; do printf '  %-12s %s\n' "$(name_of "$m")" "$(describe "$m")"; done
  exit 0
fi
if [[ ${1:-} == -h || ${1:-} == --help ]]; then
  sed -n '2,6s/^# \{0,1\}//p' "$0"; exit 0
fi

# Resolve requested module names to files.
selected=()
if (( $# == 0 )); then
  selected=("${ALL[@]}")
else
  for want in "$@"; do
    match=""
    for m in "${ALL[@]}"; do
      [[ $(name_of "$m") == "${want#[0-9]*-}" ]] && match=$m
    done
    [[ -n $match ]] || { echo "Unknown module: $want (see --list)" >&2; exit 1; }
    selected+=("$match")
  done
fi

[[ $EUID -ne 0 ]] || { echo "Run as your normal user, not root." >&2; exit 1; }

# Ask every question the selected modules need now, so the run is unattended.
mapfile -t needed < <(sed -n 's/^require //p' "${selected[@]}" | tr ' ' '\n' | awk 'NF && !seen[$0]++')
if (( ${#needed[@]} )); then
  ( source lib/common.sh; require "${needed[@]}" )
fi

# Ask for the sudo password once and keep it fresh while modules run.
sudo -v
while sleep 50; do sudo -n true; kill -0 $$ 2>/dev/null || exit; done 2>/dev/null &
trap 'kill $! 2>/dev/null' EXIT

failed=()
for m in "${selected[@]}"; do
  printf '\n\e[1;35m### %s\e[0m — %s\n' "$(name_of "$m")" "$(describe "$m")"
  bash "$m" || failed+=("$(name_of "$m")")
done

echo
if (( ${#failed[@]} )); then
  echo "Failed modules: ${failed[*]}  (fix and rerun: ./install.sh ${failed[*]})" >&2
  exit 1
fi
echo "All done."
