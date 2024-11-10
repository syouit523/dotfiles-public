#!/bin/zsh



if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # シェルの種類を判別
    SHELL_NAME=$(basename "$SHELL")
    # シェルごとの設定ファイルを決定
    case "$SHELL_NAME" in
        bash)
            CONFIG_FILE="$HOME/.bash_profile"
        ;;
        zsh)
            CONFIG_FILE="$HOME/.zshrc"
        ;;
        fish)
            CONFIG_FILE="$HOME/.config/fish/config.fish"
        ;;
        *)
            echo "未対応のシェル: $SHELL_NAME"
            exit 1
        ;;
    esac
    # 環境変数を設定
    echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> "$CONFIG_FILE"
    eval "$($(brew --prefix)/bin/brew shellenv)"

    echo "Homebrewのインストールが完了しました。"
    echo "環境変数を $CONFIG_FILE に追加しました。"
fi
