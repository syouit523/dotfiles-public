#!/bin/bash

#font
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# 最新のコミットからauthor nameとemailを取得
DEFAULT_AUTHOR_NAME=$(git log -1 --pretty=format:'%an')
DEFAULT_AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae')

# ユーザー入力を求める関数
ask_user_input() {
  local prompt="$1"
  local default_value="$2"
  local user_input

  read -p "$prompt [$default_value]: " user_input
  echo "${user_input:-$default_value}"
}

# Gitの設定を自動でセットアップ
setup_git_config() {
  # ユーザーに選択肢を提供
  echo "Configure Git settings:"
  printf "${BOLD}Do you want to change name and email? ${RESET} %s\n"
  printf " ${GREEN}Author Name: $DEFAULT_AUTHOR_NAME ${RESET} %s\n"
  printf " ${GREEN}Author Email: $DEFAULT_AUTHOR_EMAIL ${RESET} %s\n"
  read -p "Do you want to change the name and email?: [y/n]" flag
  if [[ $flag = "y" || $flag = "Y" ]]; then
    AUTHOR_NAME=$(ask_user_input "Enter Git user.name" "$DEFAULT_AUTHOR_NAME")
    AUTHOR_EMAIL=$(ask_user_input "Enter Git user.email" "$DEFAULT_AUTHOR_EMAIL")
    
    printf "${GREEN}Changed Author Name: $AUTHOR_NAME ${RESET} %s\n"
    printf "${GREEN}Changed Author Email: $AUTHOR_EMAIL ${RESET} %s\n"
  else
    AUTHOR_NAME=$DEFAULT_AUTHOR_NAME
    AUTHOR_EMAIL=$DEFAULT_AUTHOR_EMAIL
    printf "${GREEN}Using existing Name and Email... ${RESET} %s\n"
  fi

  echo "Setting up Git configurations..."
  git config --global user.name "$AUTHOR_NAME"
  git config --global user.email "$AUTHOR_EMAIL"
}

# 実行
setup_git_config

echo "Completed gitconfig setting.\n"
