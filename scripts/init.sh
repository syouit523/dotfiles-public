#!/bin/bash

set -e

REPO_URL="https://github.com/syouit523/dotfiles-public.git"
TARGET_DIR="$HOME/workspace/dotfiles-public"

# Linux: 素の環境には git / make / curl が無いことがあるため先にインストールする
# (macOS は README のワンライナーで xcode-select --install 済みの前提)
if [ "$(uname -s)" = "Linux" ]; then
    if command -v apt-get >/dev/null 2>&1; then
        # ---- apt 系 (Ubuntu 等) ----
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
    else
        # ---- apt が無いディストリ (Fedora Atomic / Bazzite 等) ----
        # Bazzite は git / curl / Homebrew をイメージに同梱している。
        # 不足するのは make だけなので brew で調達する
        # (rpm-ostree レイヤリングは公式に最終手段とされるため使わない)
        if ! command -v brew >/dev/null 2>&1 && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        if ! command -v make >/dev/null 2>&1 && ! command -v gmake >/dev/null 2>&1; then
            if command -v brew >/dev/null 2>&1; then
                echo "Installing make via Homebrew (non-apt distro)..."
                brew install make  # GNU make は gmake として入る
            else
                echo "Error: neither apt-get nor Homebrew is available." >&2
                echo "Supported: Ubuntu (apt) / Fedora Atomic with Homebrew (e.g. Bazzite)." >&2
                exit 1
            fi
        fi
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

# brew の make は gmake という名前で入るため、make が無ければフォールバック
MAKE_CMD="make"
if ! command -v make >/dev/null 2>&1 && command -v gmake >/dev/null 2>&1; then
    MAKE_CMD="gmake"
fi

echo "Setting up environment..."
"$MAKE_CMD" bootstrap
