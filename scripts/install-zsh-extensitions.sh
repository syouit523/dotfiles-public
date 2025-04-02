#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"

zsh -c 'source ~/.zshrc'

mkdir $HOME/.zsh
chmod 775 $HOME/.zsh

# fzf-git
$SCRIPTS/git-clone.sh https://github.com/junegunn/fzf-git.sh.git $HOME/.config/zsh/fzf-git

# bat
mkdir -p "$(bat --config-dir)/themes"
curl -o "$(bat --config-dir)/themes/tokyonight_night.tmTheme" https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build

# zsh-autosuggestions
$SCRIPTS/git-clone.sh https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/zsh-autosuggestions

# zsh-syntax-highlighting
$SCRIPTS/git-clone.sh https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/zsh-syntax-highlighting

zsh -c 'source ~/.zshrc'
