#!/bin/bash
# shellcheck disable=SC1071

set -eo pipefail

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    # sudoを使用せずに通常のユーザー権限で実行
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$(uname)" = 'Darwin' ]; then
        if [ "$architecture" = "arm64" ]; then
            BREW_PATH=/opt/homebrew/bin/brew  # Apple Silicon
        else
            BREW_PATH=/usr/local/bin/brew  # Intel Mac
        fi
        # .zprofile への追記は冪等にする（再インストールのたびに重複しない）
        if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo >> "$HOME"/.zprofile
            echo "eval \"\$(${BREW_PATH} shellenv)\"" >> "$HOME"/.zprofile
        fi
        eval "$("$BREW_PATH" shellenv)"
    fi
fi
