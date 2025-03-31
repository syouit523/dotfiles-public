#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# システム情報の取得
OS="$(uname -s)"
ARCH="$(uname -m)"

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
                    brew_pkg=$(echo $line | awk -F'"' '{print $2}')
                    apt_pkg=${PKG_MAP[$brew_pkg]}
                    
                    if [[ -n "$apt_pkg" ]]; then
                        echo "$brew_pkg をインストール中 (aptパッケージ: $apt_pkg)..."
                        # APT_ARGSで対話プロンプトを無効化
                        sudo APT_ARGS="-o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'" apt-get install -y $apt_pkg
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
        echo "pyenvをインストール中..."
        curl https://pyenv.run | bash
    else
        echo "サポートされていないOSです: $OS"
        exit 1
    fi
}

install_tfenv() {
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    touch .bash_profile
    echo export PATH='$HOME/.tfenv/bin:$PATH' >> ~/.bash_profile
    source ~/.bash_profile
}

install_tailscale() {
    curl -fsSL https://tailscale.com/install.sh | sh
}

setup_bat() {
    # ref: https://github.com/sharkdp/bat?tab=readme-ov-file#on-ubuntu-using-apt
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
}

install_packages
install_pyenv
install_tfenv
install_tailscale
install_starship
setup_bat