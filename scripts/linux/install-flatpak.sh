#!/bin/bash

set -e

# App Install Manager
## Install flatpak (PPA 追加後に1回だけインストールする)
## Fedora Atomic 系 (Bazzite 等) は flatpak + Flathub リモートが
## 設定済みのため、インストール処理はスキップする
if command -v apt-get >/dev/null 2>&1; then
    sudo add-apt-repository -y ppa:flatpak/stable
    sudo apt update
    sudo apt install flatpak -y
    sudo apt install gnome-software-plugin-flatpak -y
elif command -v flatpak >/dev/null 2>&1; then
    echo "flatpak is already available (non-apt distro). Skipping installation."
else
    echo "Error: no apt-get and no flatpak found. Install flatpak manually." >&2
    exit 1
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
