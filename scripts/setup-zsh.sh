#!/bin/bash

# # リポジトリURLとターゲットディレクトリを設定
# REPO_URL="https://github.com/syouit523/dotfiles-public.git"
# TARGET_DIR="$HOME/workspace/dotfiles-public"

# # リポジトリが既に存在するかチェック
# if [ ! -d "$TARGET_DIR" ]; then
#     echo "Cloning dotfiles repository..."
#     git clone "$REPO_URL" "$TARGET_DIR"
# fi

# # ターゲットディレクトリに移動
# cd "$TARGET_DIR" || exit

# echo "Setting up environment..."
# make bootstrap

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k