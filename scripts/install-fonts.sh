#!/bin/bash

echo "Installing fonts...\n"
if [ ! -d "nerd-fonts" ]; then
    git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git
fi
nerd-fonts/install.sh
echo "Installed fonts!!"
