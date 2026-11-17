#!/usr/bin/env bash
# desc: zsh + oh-my-zsh (git aliases, autosuggestions, highlighting), starship prompt
source "$(dirname "$0")/../lib/common.sh"

pkgs zsh starship fnm

# clone_or_update URL DIR — shallow clone, or fast-forward if already there.
clone_or_update() {
  if [[ -d $2/.git ]]; then
    git -C "$2" pull -q --ff-only && ok "updated ${2/#$HOME/\~}"
  else
    git clone -q --depth=1 "$1" "$2" && ok "cloned ${2/#$HOME/\~}"
  fi
}

ZSH_DIR="$HOME/.oh-my-zsh"
clone_or_update https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  clone_or_update "https://github.com/zsh-users/$p" "$ZSH_DIR/custom/plugins/$p"
done

zsh_path=$(command -v zsh)
if [[ $(getent passwd "$USER" | cut -d: -f7) != "$zsh_path" ]]; then
  sudo chsh -s "$zsh_path" "$USER"
  ok "login shell set to zsh (takes effect on next login)"
fi

ok "Shell ready (~/.zshrc and starship.toml come from the dotfiles module)"
