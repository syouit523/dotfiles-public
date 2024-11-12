#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# システム情報の取得
OS="$(uname -s)"
ARCH="$(uname -m)"


# Homebrewのパッケージインストール
install_brew_packages() {
  SHARED_BREWFILE="$ROOT_DIR/shared/Brewfile"
  MAC_BREWFILE="$ROOT_DIR/mac/Brewfile"
  
  if [[ "$OS" == "Darwin" ]]; then
        # macOSの場合
        if [[ "$ARCH" == "arm64" ]]; then
            # Apple Siliconの場合
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel Macの場合
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        # Brewfileの読み込み
        sudo -n brew bundle --file="$SHARED_BREWFILE" || true
        sudo -n brew bundle --file="$MAC_BREWFILE" || true
    elif [[ "$OS" == "Linux" ]]; then
        # Linuxの場合
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        sudo -n brew bundle --file="$SHARED_BREWFILE" || true
    else
        echo "サポートされていないOSです: $OS"
        exit 1
    fi
}

install_brew_packages
