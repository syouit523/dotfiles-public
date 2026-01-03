#!/bin/bash
# shellcheck disable=SC1071

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    # sudoを使用せずに通常のユーザー権限で実行
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$(uname)" = 'Darwin' ]; then
        echo >> "$HOME"/.zprofile
        if [ "$architecture" = "arm64" ]; then
            # Set the path for Apple Silicon
            # shellcheck disable=SC2016
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME"/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Set the path for Intel Mac
            # shellcheck disable=SC2016
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME"/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        # shellcheck disable=SC1091
        source "$HOME"/.zprofile
    fi
fi
