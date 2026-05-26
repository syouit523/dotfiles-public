#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"

mkdir -p "$HOME/.zsh"
chmod 775 "$HOME/.zsh"

# fzf-git
"$SCRIPTS"/git-clone.sh https://github.com/junegunn/fzf-git.sh.git "$HOME"/.config/zsh/fzf-git

# bat (tokyonight theme)
if command -v bat >/dev/null 2>&1; then
    mkdir -p "$(bat --config-dir)/themes"
    curl -fsSL -o "$(bat --config-dir)/themes/tokyonight_night.tmTheme" \
        https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
    bat cache --build
fi

# zsh-autosuggestions
"$SCRIPTS"/git-clone.sh https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.zsh/zsh-autosuggestions

# zsh-syntax-highlighting
"$SCRIPTS"/git-clone.sh https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.zsh/zsh-syntax-highlighting
