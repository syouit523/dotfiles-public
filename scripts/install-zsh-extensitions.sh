#!/bin/bash

zsh -c 'source ~/.zshrc'

# fzf-git
./git-clone.sh https://github.com/junegunn/fzf-git.sh.git $HOME/.config/zsh/fzf-git

# bat
mkdir -p "$(bat --config-dir)/themes"
curl -o "$(bat --config-dir)/themes/tokyonight_night.tmTheme" https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build

# zsh-autosuggestions
./git-clone.sh https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/zsh-autosuggestions

# zsh-syntax-highlighting
./git-clone.sh https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/zsh-syntax-highlighting

zsh -c 'source ~/.zshrc'
