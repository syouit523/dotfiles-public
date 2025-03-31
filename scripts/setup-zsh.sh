#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"
ZSH_PATH=$(which zsh)

if command -v zsh >/dev/null 2>&1; then
    # set to the default shell to zsh
    # sudo -n sed -i.bak '/\/bin\/zsh/d' /etc/shells # remove existing zsh path for mac
    if ! grep -q "^$ZSH_PATH$" /etc/shells; then
        if [ "$(uname)" == 'Darwin' ]; then
            if [ "$(uname -m)" == x86_64 ]; then
                sh -c "echo \"$ZSH_PATH\" >> /etc/shells" # add zsh path of homebrew
            elif [ "$(uname -m)" == arm64 ]; then
                sh -c "echo \"$ZSH_PATH\" >> /etc/shells" # add zsh path of homebrew
            fi
        elif [ "$(uname)" == 'Linux' ]; then
            if [ -f /etc/shells ]; then
                sh -c "echo \"$ZSH_PATH\" >> /etc/shells" # add zsh path of apt
            fi
        fi
    fi
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
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        $SCRIPTS/git-clone.sh https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi

    # theme
    ## zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        $SCRIPTS/git-clone.sh https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    ## zsh-syntax-highlighting
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        $SCRIPTS/git-clone.sh https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

else
    echo "zsh is not installed."
    exit
fi
