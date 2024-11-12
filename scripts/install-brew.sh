#!/bin/zsh

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    # sudoを使用せずに通常のユーザー権限で実行
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$(uname)" = 'Darwin' ]; then
        echo >> $HOME/.zprofile
        if [ "$architecture" = "arm64" ]; then
            # Set the path for Apple Silicon
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Set the path for Intel Mac
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        source $HOME/.zprofile
    fi
fi
