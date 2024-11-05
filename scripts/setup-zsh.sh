#!/bin/bash

if command -v zsh >/dev/null 2>&1; then
    # set to the default shell to zsh
    chsh -s $(which zsh)
    zdh
    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    zsh -c 'source ~/.zshrc'
    # theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # install plugins of oh-my-zsh
    ## zsh-autosuggestions
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ## zsh-syntax-highlighting
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

else
    echo "zsh is not installed."
    exit
fi