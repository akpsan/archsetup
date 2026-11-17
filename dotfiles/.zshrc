export PATH="$HOME/.local/bin:$PATH"

# --- oh-my-zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # prompt is handled by starship below
plugins=(
  git                      # gst, gco, gcb, gaa, gcmsg, gp, gl, glog, gd ...
  fnm
  zsh-autosuggestions
  zsh-syntax-highlighting  # keep last
)
source "$ZSH/oh-my-zsh.sh"

# --- history ---
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# --- node (fnm) ---
eval "$(fnm env --use-on-cd --shell zsh)"

# --- prompt ---
command -v starship >/dev/null && eval "$(starship init zsh)"
