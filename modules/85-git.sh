#!/usr/bin/env bash
# desc: global git identity and sane defaults
source "$(dirname "$0")/../lib/common.sh"
require GIT_NAME GIT_EMAIL

pkgs git
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase true
ok "git: $GIT_NAME <$GIT_EMAIL>"
