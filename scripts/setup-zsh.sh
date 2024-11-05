#!/bin/bash

if command -v zsh >/dev/null 2>&1; then
    # set to the default shell to zsh
    chsh -s $(which zsh)
    zdh

    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed."
    else
        echo "Oh My Zsh is not installed. Installing now..."
        
        # Install oh-my-zsh without changing the shell immediately
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        echo "Oh My Zsh installation completed."
    fi

    if [ -n "$ZSH_VERSION" ]; then
        source ~/.zshrc
    fi
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