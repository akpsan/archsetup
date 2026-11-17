# zsh login shell: start Hyprland on tty1 (zsh equivalent of .bash_profile)
if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec start-hyprland
fi
