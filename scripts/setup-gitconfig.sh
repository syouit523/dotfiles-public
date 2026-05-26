#!/bin/bash

GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

DEFAULT_AUTHOR_NAME=$(git log -1 --pretty=format:'%an' 2>/dev/null || echo "")
DEFAULT_AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae' 2>/dev/null || echo "")

ask_user_input() {
  local prompt="$1"
  local default_value="$2"
  local user_input

  read -r -p "$prompt [$default_value]: " user_input
  echo "${user_input:-$default_value}"
}

setup_git_config() {
  if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    AUTHOR_NAME="$GIT_USER_NAME"
    AUTHOR_EMAIL="$GIT_USER_EMAIL"
    printf "${GREEN}Using env vars: %s <%s>${RESET}\n" "$AUTHOR_NAME" "$AUTHOR_EMAIL"
  elif [ "$NONINTERACTIVE" = "1" ]; then
    AUTHOR_NAME="$DEFAULT_AUTHOR_NAME"
    AUTHOR_EMAIL="$DEFAULT_AUTHOR_EMAIL"
    printf "${GREEN}NONINTERACTIVE: using defaults %s <%s>${RESET}\n" "$AUTHOR_NAME" "$AUTHOR_EMAIL"
  else
    echo "Configure Git settings:"
    printf "${BOLD}Do you want to change name and email?${RESET}\n"
    printf " ${GREEN}Author Name: %s${RESET}\n" "$DEFAULT_AUTHOR_NAME"
    printf " ${GREEN}Author Email: %s${RESET}\n" "$DEFAULT_AUTHOR_EMAIL"
    read -r -p "Do you want to change the name and email?: [y/N]" flag
    if [[ $flag = "y" || $flag = "Y" ]]; then
      AUTHOR_NAME=$(ask_user_input "Enter Git user.name" "$DEFAULT_AUTHOR_NAME")
      AUTHOR_EMAIL=$(ask_user_input "Enter Git user.email" "$DEFAULT_AUTHOR_EMAIL")
      printf "${GREEN}Changed Author Name: %s${RESET}\n" "$AUTHOR_NAME"
      printf "${GREEN}Changed Author Email: %s${RESET}\n" "$AUTHOR_EMAIL"
    else
      AUTHOR_NAME=$DEFAULT_AUTHOR_NAME
      AUTHOR_EMAIL=$DEFAULT_AUTHOR_EMAIL
      printf "${GREEN}Using existing Name and Email...${RESET}\n"
    fi
  fi

  if [ -z "$AUTHOR_NAME" ] || [ -z "$AUTHOR_EMAIL" ]; then
    echo "Skipping git config: name/email is empty"
    return 0
  fi

  echo "Setting up Git configurations..."
  git config --global user.name "$AUTHOR_NAME"
  git config --global user.email "$AUTHOR_EMAIL"
}

setup_git_config

printf "Completed gitconfig setting.\n"
