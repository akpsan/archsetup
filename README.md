# archsetup

Turns a fresh Arch install into a Hyprland desktop. Every module is safe to rerun.

## Fresh machine

1. Install base Arch (archinstall is fine) with a user that has sudo, GRUB, and NetworkManager.
2. Log in on tty1, then:
   ```sh
   sudo pacman -S --needed git
   git clone <this repo> ~/work/archsetup
   cd ~/work/archsetup
   ./install.sh
   ```
3. Reboot when it asks (it lists why, and only asks when something needs it).
   Logging in on tty1 starts Hyprland.
4. Open Timeshift once: RSYNC mode, root disk, set a schedule.

## Usage

```sh
./install.sh                 # everything, in order
./install.sh --list          # what's available
./install.sh dotfiles git    # only these modules, by name
bash modules/80-dotfiles.sh  # any module also runs on its own
```

## Layout

| Path | What |
|---|---|
| `install.sh` | Runs modules in numeric order; asks for sudo once |
| `modules/NN-name.sh` | One concern each; `# desc:` line shows in `--list` |
| `lib/common.sh` | Helpers: `pkgs`, `aur`, `enable_now`, `write_root`, `set_conf`, `needs_reboot` |
| `settings.conf` | Shared, non-personal defaults (zram size) |
| `settings.local.conf` | Your answers to first-run questions: git identity, mirror countries (gitignored) |
| `dotfiles/` | Mirrors `$HOME`; symlinked in by the `dotfiles` module |

## Dotfiles

Files in `~` are symlinks into `dotfiles/`, so editing `~/.config/...` edits the repo.
Commit from here. Replaced files are backed up to `~/.dotfiles-backup/<timestamp>/`.

To track a new file: move it into `dotfiles/` at the same relative path, then run
`./install.sh dotfiles`.

## Personal settings

Nothing personal is committed. On first run `install.sh` asks for your git name/email
and mirror countries (all questions up front, so the rest runs unattended) and saves
them to `settings.local.conf`. Edit or delete that file to change or re-answer.
In a module, `require VAR` declares a needed setting; add its question to `PROMPTS`
in `lib/common.sh`.

## Adding a module

Create `modules/NN-name.sh`:

```bash
#!/usr/bin/env bash
# desc: one line about what it does
source "$(dirname "$0")/../lib/common.sh"

pkgs some-package
enable_now some.service
```

If a change only applies after a reboot, call `needs_reboot "reason"` when it
actually happens (not on every run).

Keep it rerunnable: use `pkgs` (skips installed), `write_root` (only writes on change),
and check state before one-off actions.
