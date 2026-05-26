#!/bin/bash

REPO_URL="https://github.com/syouit523/dotfiles-public.git"
TARGET_DIR="$HOME/workspace/dotfiles-public"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning dotfiles repository..."
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR" || exit 1

echo "Setting up environment..."
make bootstrap
