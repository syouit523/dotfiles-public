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
        # brew bundle の並列インストールはロック競合で稀に一部 formula が
        # 失敗する (例: "process has already locked .../Cellar/<dep>")。
        # 失敗時は一度だけリトライする。
        if ! brew bundle --file="$brewfile"; then
          echo "brew bundle failed for $brewfile; retrying once..."
          brew bundle --file="$brewfile" || true
        fi
        # リトライ後も未充足なら失敗として扱う。
        # 警告だけで exit 0 するとパッケージ欠落のまま bootstrap が
        # 「成功」扱いになり、CI でも検出できないため fail-fast にする。
        if ! brew bundle check --file="$brewfile"; then
          echo "Error: some packages in $brewfile are still missing after retry:" >&2
          brew bundle check --verbose --file="$brewfile" >&2 || true
          exit 1
        fi
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
