#!/bin/bash

set -e

# $SCRIPTS は Makefile から export される。単体実行時のフォールバックを用意。
SCRIPTS="${SCRIPTS:-$(cd "$(dirname "$0")" && pwd)}"
ROOT_DIR="$(cd "$SCRIPTS/.." && pwd)"

# インストールするフォント（configs のターミナル設定が使うもののみ）
# - Hack Nerd Font: Ghostty
# - MesloLGS Nerd Font: WezTerm / VSCode / p10k 推奨フォント
FONTS=(Hack Meslo)

NERD_FONTS_DIR="$ROOT_DIR/deps/nerd-fonts"

printf "Installing fonts: %s\n" "${FONTS[*]}"

# nerd-fonts リポジトリは全フォント込みで数GBあるため、
# blobless + sparse checkout で必要なフォントだけ取得する
# (cone モードではリポジトリ直下のファイル = install.sh は常に含まれる)
if [ ! -d "$NERD_FONTS_DIR/.git" ]; then
    rm -rf "$NERD_FONTS_DIR"
    mkdir -p "$ROOT_DIR/deps"
    git clone --depth 1 --filter=blob:none --sparse \
        https://github.com/ryanoasis/nerd-fonts.git "$NERD_FONTS_DIR"
fi

cd "$NERD_FONTS_DIR"
sparse_dirs=()
for font in "${FONTS[@]}"; do
    sparse_dirs+=("patched-fonts/$font")
done
git sparse-checkout set "${sparse_dirs[@]}"

if [ ! -x "$NERD_FONTS_DIR/install.sh" ]; then
    echo "nerd-fonts install.sh not found at $NERD_FONTS_DIR"
    exit 1
fi

# install.sh は macOS では ~/Library/Fonts、Linux では
# ~/.local/share/fonts へのインストールと fc-cache 実行を行う
for font in "${FONTS[@]}"; do
    "$NERD_FONTS_DIR/install.sh" "$font"
done

echo "Installed fonts!!"
