#!/bin/bash

if command -v zsh >/dev/null 2>&1; then
    # set to the default shell to zsh
    if [ "$(uname)" == 'Darwin' ]; then
      sudo -n sed -i.bak '/\/bin\/zsh/d' /etc/shells # remove existing zsh path for mac
      if [ "$(uname -m)" == x86_64 ]; then
        sudo -n sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells' # add zsh path of homebrew
      elif [ "$(uname -m)" == arm64 ]; then
        sudo -n sh -c 'echo "/opt/homebrew/bin/zsh" >> /etc/shells' # add zsh path of homebrew
      fi
    fi
    sudo -n chsh -s $(which zsh)
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
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi

    # install plugins of oh-my-zsh
    ## zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    ## zsh-syntax-highlighting
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

else
    echo "zsh is not installed."
    exit
fi
