#!/usr/bin/env bash
# desc: symlink dotfiles/ into $HOME (existing files are backed up first)
source "$(dirname "$0")/../lib/common.sh"

backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
backed_up=0

while IFS= read -r -d '' src; do
  rel=${src#"$DOTFILES_DIR"/}
  dst="$HOME/$rel"
  if [[ -L $dst && $(readlink -f "$dst") == "$(readlink -f "$src")" ]]; then
    continue                                   # already linked
  fi
  if [[ -e $dst || -L $dst ]]; then
    mkdir -p "$backup/$(dirname "$rel")"
    mv "$dst" "$backup/$rel"
    warn "backed up ~/$rel"
    backed_up=1
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "linked ~/$rel"
done < <(find "$DOTFILES_DIR" -type f -print0)

(( backed_up )) && log "Old files saved in $backup"
ok "Dotfiles in place"
