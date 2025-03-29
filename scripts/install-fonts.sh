#!/bin/bash

echo "Installing fonts...\n"
# Install Nerd Fonts
$SCRIPTS/git-clone.sh https://github.com/ryanoasis/nerd-fonts.git
$CLONED_DIR_PATH/nerd-fonts/install.sh
echo "Installed fonts!!"
