#!/bin/bash
# shellcheck disable=SC1071

set -eo pipefail

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    # sudoを使用せずに通常のユーザー権限で実行
    # (インストーラ内部で必要な箇所だけ sudo を使う。NONINTERACTIVE=1 は
    #  Makefile から export され、インストーラのプロンプトを抑止する)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ "$(uname)" = 'Darwin' ]; then
        if [ "$architecture" = "arm64" ]; then
            BREW_PATH=/opt/homebrew/bin/brew  # Apple Silicon
        else
            BREW_PATH=/usr/local/bin/brew  # Intel Mac
        fi
        PROFILES=("$HOME/.zprofile")
    else
        # Homebrew on Linux (公式推奨プレフィックス)
        BREW_PATH=/home/linuxbrew/.linuxbrew/bin/brew
        # ログインシェルが bash でも zsh でも効くよう両方に追記する
        PROFILES=("$HOME/.profile" "$HOME/.zprofile")
    fi

    if [ ! -x "$BREW_PATH" ]; then
        echo "Error: brew not found at $BREW_PATH after installation." >&2
        exit 1
    fi

    # プロファイルへの追記は冪等にする（再インストールのたびに重複しない）
    for profile in "${PROFILES[@]}"; do
        if ! grep -q 'brew shellenv' "$profile" 2>/dev/null; then
            echo >> "$profile"
            echo "eval \"\$(${BREW_PATH} shellenv)\"" >> "$profile"
        fi
    done
    eval "$("$BREW_PATH" shellenv)"
fi
