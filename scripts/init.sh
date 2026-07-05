#!/bin/bash

set -e

REPO_URL="https://github.com/syouit523/dotfiles-public.git"
TARGET_DIR="$HOME/workspace/dotfiles-public"

# Linux: 素の環境には git / make / curl が無いことがあるため先にインストールする
# (macOS は README のワンライナーで xcode-select --install 済みの前提)
if [ "$(uname -s)" = "Linux" ]; then
    missing=""
    for cmd in git make curl; do
        command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
    done
    if [ "$(id -u)" -eq 0 ]; then
        # root (素のコンテナ等) では sudo 自体が無いことがある。
        # 後続の Makefile が sudo を使うため、sudo も併せて導入する
        if [ -n "$missing" ] || ! command -v sudo >/dev/null 2>&1; then
            echo "Installing prerequisites (as root):$missing sudo"
            apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get install -y git make curl sudo
        fi
    elif [ -n "$missing" ]; then
        echo "Installing prerequisites:$missing"
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git make curl
    fi
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning dotfiles repository..."
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
elif [ ! -f "$TARGET_DIR/Makefile" ]; then
    # 中断された clone の残骸や無関係のディレクトリで
    # 不可解なエラーになるのを防ぐ
    echo "Error: $TARGET_DIR exists but does not look like the dotfiles repository." >&2
    echo "Remove or rename it, then re-run this script." >&2
    exit 1
fi

cd "$TARGET_DIR" || exit 1

echo "Setting up environment..."
make bootstrap
