#!/bin/bash

zsh -c 'source ~/.zshrc'

# fzf-git
git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git $HOME/.config/zsh/fzf-git

# bat
mkdir -p "$(bat --config-dir)/themes"
curl -o "$(bat --config-dir)/themes/tokyonight_night.tmTheme" https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build


zsh -c 'source ~/.zshrc'
