#!/bin/bash

# Install wezterm(terminal)
## ref: https://wezfurlong.org/wezterm/index.html
flatpak install flathub orz.wezfurlong.wezterm -y
flatpak run orz.wezfurlong.wezterm
alias wezterm="flatpak run orz.wezfurlong.wezterm"
