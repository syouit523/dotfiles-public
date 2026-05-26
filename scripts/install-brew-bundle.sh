#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# システム情報の取得
OS="$(uname -s)"
ARCH="$(uname -m)"

# 使用方法表示
show_usage() {
  echo "使用方法: $0 [minimum|extra]"
  echo "  minimum: 最小限のパッケージのみインストール (minimum-Brewfile)"
  echo "  extra:   追加パッケージもインストール (extra-Brewfile)"
  echo "  引数なし: インストールしない"
}

# Homebrewのパッケージインストール
install_brew_packages() {
  local mode="${1:-minimum}" # デフォルトはminimum
  
  # Brewfileの選択
  case "$mode" in
    minimum)
      BREWFILES=("$ROOT_DIR/Brewfiles/minimum-Brewfile")
      ;;
    extra|"")
      BREWFILES=(
        "$ROOT_DIR/Brewfiles/minimum-Brewfile"
        "$ROOT_DIR/Brewfiles/extra-Brewfile"
      )
      ;;
    *)
      show_usage
      exit 1
      ;;
  esac
  
  if [[ "$OS" == "Darwin" ]]; then
        # macOSの場合
        if [[ "$ARCH" == "arm64" ]]; then
            # Apple Silicon
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel Mac
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    elif [[ "$OS" == "Linux" ]]; then
        # Linuxbrew
        if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif command -v brew >/dev/null 2>&1; then
            eval "$(brew shellenv)"
        else
            echo "Homebrew not found on Linux. Skipping brew bundle."
            exit 0
        fi
    else
        echo "Unsupported OS: $OS"
        exit 1
    fi
    
    # 選択されたBrewfileをインストール
    for brewfile in "${BREWFILES[@]}"; do
      if [[ -f "$brewfile" ]]; then
        echo "Installing from $brewfile..."
        brew bundle --file="$brewfile" || true
      else
        echo "Brewfile not found: $brewfile"
        exit 1
      fi
    done
}

# メイン処理
if [[ $# -ne 1 ]]; then
  show_usage
  exit 1
fi

install_brew_packages "$1"
