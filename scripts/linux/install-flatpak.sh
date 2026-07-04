#!/bin/bash

set -e

# App Install Manager
## Install flatpak (PPA 追加後に1回だけインストールする)
sudo add-apt-repository -y ppa:flatpak/stable
sudo apt update
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
