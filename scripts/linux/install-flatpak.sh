#!/bin/bash

# App Install Manager
## Install flatpak
sudo apt install flatpak -y
sudo add-apt-repository ppa:flatpak/stable
sudo apt update
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo