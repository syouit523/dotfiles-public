#!/bin/zsh

# Apple SiliconのHomebrewパス
# BREW_PATH="/opt/homebrew/bin/brew"

# `--print-path` オプションが指定されている場合は、HomebrewのPATH設定を出力して終了
# if [[ "$1" == "--print-path" ]]; then
#     if [[ -x $BREW_PATH ]]; then
#         echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
#     fi
#     exit 0
# fi

# # Homebrewのインストール確認
# if command -v brew >/dev/null 2>&1; then
#     echo "Homebrew is already installed."
# else
#     echo "Installing Homebrew..."
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi

# # PATH設定
# if [[ -x $BREW_PATH ]]; then
#     echo "Configuring Homebrew PATH..."
#     echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
#     eval "$(/opt/homebrew/bin/brew shellenv)"
# else
#     echo "Error: Homebrew installation path not found."
# fi

# Apple SiliconのHomebrewパス
# BREW_PATH="/opt/homebrew/bin/brew"

# # Homebrewのインストール確認
# if command -v brew >/dev/null 2>&1; then
#     echo "Homebrew is already installed."
# else
#     echo "Installing Homebrew..."
#     sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
# fi

# # PATH設定
# if [[ -x $BREW_PATH ]]; then
#     echo "Configuring Homebrew PATH..."
#     echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
#     eval "$(/opt/homebrew/bin/brew shellenv)"
# else
#     echo "Error: Homebrew installation path not found."
# fi

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
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


# architecture=$(uname -m)

# if command -v brew >/dev/null 2>&1; then
#     echo "brew is already installed."
#     echo "skip installing brew"
# else
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#     if [ "$(uname)" = 'Darwin' ]; then
# 	    echo >> $HOME/.zprofile
#         if [ "$architecture" = "arm64" ]; then
#         # for Apple silicon
# 	    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
#      	    eval "$(/opt/homebrew/bin/brew shellenv)"
# 	    export PATH="$PATH:/opt/homebrew/bin/brew/"
# 	    #(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
# 	    #eval "$(/opt/homebrew/bin/brew shellenv)"
#      	    source $HOME/.zprofile
#         fi
#     fi
# fi
