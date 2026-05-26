#!/bin/bash

set -e

# $SCRIPTS は Makefile から export される。単体実行時のフォールバックを用意。
SCRIPTS="${SCRIPTS:-$(cd "$(dirname "$0")" && pwd)}"
ROOT_DIR="$(cd "$SCRIPTS/.." && pwd)"

printf "Installing fonts...\n"

# Nerd Fonts を clone（git-clone.sh は cwd の deps/ 配下にcloneする）
cd "$ROOT_DIR"
"$SCRIPTS/git-clone.sh" https://github.com/ryanoasis/nerd-fonts.git

# git-clone.sh の export は子プロセスで死ぬため、ここで直接パスを組み立てる
NERD_FONTS_DIR="$ROOT_DIR/deps/nerd-fonts"
if [ ! -x "$NERD_FONTS_DIR/install.sh" ]; then
    echo "nerd-fonts install.sh not found at $NERD_FONTS_DIR"
    exit 1
fi

"$NERD_FONTS_DIR/install.sh"
echo "Installed fonts!!"
