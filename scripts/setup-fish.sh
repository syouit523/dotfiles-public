#!/opt/homebrew/bin/fish

# change the default shell to fish
chsh -s $(which fish)
# change the shell in the current one
fish
# install fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
# install all packages in ~/.config/fish/fish_plugins
fisher update