#!/usr/bin/env bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# システム情報の取得
OS="$(uname -s)"
ARCH="$(uname -m)"

# 対話的なインストールを防ぐための設定
export DEBIAN_FRONTEND=noninteractive
echo "iperf3 iperf3/autostart boolean false" | sudo debconf-set-selections

# brewパッケージからaptパッケージへのマッピング
declare -A PKG_MAP=(
    ["eza"]="eza"
    ["fd"]="fd-find"
    ["bat"]="bat"
    ["micro"]="micro"
    ["jq"]="jq"
    ["git-delta"]="git-delta"
    ["curl"]="curl"
    ["wget"]="wget"
    ["nmap"]="nmap"
    ["iperf3"]="iperf3"
    ["fish"]="fish"
    ["zsh"]="zsh"
    ["fzf"]="fzf"
    ["tmux"]="tmux"
    ["direnv"]="direnv"
    ["gh"]="gh"
    ["git"]="git"
    ["git-lfs"]="git-lfs"
    ["go"]="golang"
    ["node"]="nodejs"
    ["neovim"]="neovim"
    ["pyenv"]="pyenv"
    ["rbenv"]="rbenv"
    ["ruby-build"]="ruby-build"
    ["tfenv"]="tfenv"
    ["optipng"]="optipng"
    ["nkf"]="nkf"
    ["tcl-tk"]="tcl tk"
    ["tree"]="tree"
    ["ripgrep"]="ripgrep"
    ["starship"]="starship"
    ["zoxide"]="zoxide"
    ["awscli"]="awscli"
    ["tailscale"]="tailscale"
    ["coreutils"]="coreutils"
    ["ffmpeg"]="ffmpeg"
)

# パッケージインストール
install_packages() {
    # minimumとextraのBrewfileを処理
    BREWFILES=(
        "$ROOT/Brewfiles/minimum-Brewfile"
        "$ROOT/Brewfiles/extra-Brewfile"
    )
    
    if [[ "$OS" == "Linux" ]]; then
        echo "debconf-utilsをインストール中..."
        sudo apt-get install -y debconf-utils
        
        echo "パッケージリストを更新中..."
        sudo apt-get update
        
        echo "Brewfileからaptでパッケージをインストール中..."
        for BREWFILE in "${BREWFILES[@]}"; do
            echo "処理中: $BREWFILE"
            while IFS= read -r line; do
                if [[ $line == brew* ]]; then
                    brew_pkg=$(echo $line | awk -F'"' '{print $2}')
                    apt_pkg=${PKG_MAP[$brew_pkg]}
                    
                    if [[ -n "$apt_pkg" ]]; then
                        echo "$brew_pkg をインストール中 (aptパッケージ: $apt_pkg)..."
                        sudo apt-get install -y --force-yes $apt_pkg
                    else
                        echo "警告: $brew_pkg のaptパッケージマッピングがありません"
                    fi
                fi
            done < "$BREWFILE"
        done
    else
        echo "サポートされていないOSです: $OS"
        exit 1
    fi
}

install_packages
