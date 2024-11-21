#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# システム情報の取得
OS="$(uname -s)"
ARCH="$(uname -m)"

# パッケージインストール
install_packages() {
  SHARED_BREWFILE="$ROOT_DIR/shared/Brewfile"
  
  if [[ "$OS" == "Linux" ]]; then
        echo "Updating package list..."
        sudo apt update
        
        echo "Installing packages from Brewfile using apt..."
        while IFS= read -r line; do
            if [[ $line == brew* ]]; then
                package=$(echo $line | awk '{print $2}')
                echo "Installing $package..."
                sudo apt install -y $package
            fi
        done < "$SHARED_BREWFILE"
    else
        echo "サポートされていないOSです: $OS"
        exit 1
    fi
}

install_packages