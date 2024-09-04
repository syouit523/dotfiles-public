#!/bin/bash

if command -v zsh >/dev/null 2>&1; then
    # set to the default shell to zsh
    chsh -s $(which zsh)
    zdh
    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

else
    echo "zsh is not installed."
    exit
fi