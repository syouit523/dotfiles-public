#!/bin/bash

# Install wezterm(terminal)
## ref: https://wezfurlong.org/wezterm/index.html
flatpak install flathub org.wezfurlong.wezterm
flatpak run org.wezfurlong.wezterm
alias wezterm="flatpak run org.wezfurlong.wezterm"
