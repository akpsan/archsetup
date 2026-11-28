#!/usr/bin/env bash
# desc: global git identity and sane defaults, GitHub CLI
source "$(dirname "$0")/../lib/common.sh"
require GIT_NAME GIT_EMAIL

pkgs git github-cli
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase true
ok "git: $GIT_NAME <$GIT_EMAIL>"
gh auth status &>/dev/null || warn "GitHub CLI not logged in; run: gh auth login"
