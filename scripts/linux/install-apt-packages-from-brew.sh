#!/bin/bash

set -eo pipefail

# システム情報の取得
OS="$(uname -s)"

# Makefile 経由 (export ROOT) 以外で単体実行された場合のフォールバック
ROOT="${ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

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
    ["rbenv"]="rbenv"
    ["ruby-build"]="ruby-build"
    ["optipng"]="optipng"
    ["nkf"]="nkf"
    ["tcl-tk"]="tcl tk"
    ["tree"]="tree"
    ["ripgrep"]="ripgrep"
    ["zoxide"]="zoxide"
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
                    brew_pkg=$(echo "$line" | awk -F'"' '{print $2}')
                    apt_pkg=${PKG_MAP[$brew_pkg]}

                    if [[ -n "$apt_pkg" ]]; then
                        echo "$brew_pkg をインストール中 (aptパッケージ: $apt_pkg)..."
                        # 設定ファイル衝突時の対話プロンプトを無効化
                        # (環境変数 APT_ARGS は apt に解釈されないため引数で直接渡す)
                        # "tcl tk" のような複数パッケージのマッピングに対応するため配列に分割
                        read -ra apt_pkgs <<< "$apt_pkg"
                        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                            -o Dpkg::Options::=--force-confdef \
                            -o Dpkg::Options::=--force-confold \
                            "${apt_pkgs[@]}"
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

install_starship() {
    if [[ "$OS" == "Linux" ]]; then
        echo "starshipをインストール中..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    else
        echo "サポートされていないOSです: $OS"
        exit 1
    fi
}

install_pyenv() {
    if [[ "$OS" == "Linux" ]]; then
        # pyenv.run は ~/.pyenv が既存だと失敗して set -e で全体が中断するため、
        # 既存ならスキップして冪等にする
        if [ -d "$HOME/.pyenv" ]; then
            echo "pyenvはすでにインストールされています。スキップします。"
            return 0
        fi
        echo "pyenvをインストール中..."
        curl -fsSL https://pyenv.run | bash
    else
        echo "サポートされていないOSです: $OS"
        exit 1
    fi
}

install_tfenv() {
    if [ ! -d "$HOME/.tfenv" ]; then
        git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
    fi
    touch ~/.bash_profile
    if ! grep -q '\.tfenv/bin' ~/.bash_profile; then
        echo "export PATH=\"\$HOME/.tfenv/bin:\$PATH\"" >> ~/.bash_profile
    fi
    export PATH="$HOME/.tfenv/bin:$PATH"
}

install_tailscale() {
    curl -fsSL https://tailscale.com/install.sh | sh
}

setup_bat() {
    # ref: https://github.com/sharkdp/bat?tab=readme-ov-file#on-ubuntu-using-apt
    if [ ! -f /usr/bin/batcat ]; then
        echo "batcatが見つかりません。batのリンク作成をスキップします。"
        return 0
    fi
    mkdir -p ~/.local/bin
    ln -sfn /usr/bin/batcat ~/.local/bin/bat
}

install_packages
install_pyenv
install_tfenv
install_tailscale
install_starship
setup_bat