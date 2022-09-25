#!/opt/homebrew/bin/fish

curl -sL https://git.io/fisher | source ${SHELL} && fisher install jorgebucaran/fisher
fisher install ilancosman/tide@v5;