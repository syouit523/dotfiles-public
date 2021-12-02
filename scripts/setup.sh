#!/bin/bash

set -e

PLATFORM=$(uname); export PLATFORM
WORKSPACE="$HOME"/workspace
DOTPATH="$WORKSPACE"/dotfiles-public; export DOTPATH
DOTFILES_GITHUB="https://github.com/syouit523/dotfiles.git"; export DOTFILES_GITHUB

initialize () {
  if [ ! -x "$(which xcode-select -p)" ]; then
    xcode-select install
  fi
}

make_workspace () {
  if [ ! -d "$WORKSPACE" ];then
    mkdir "$WORKSPACE"
  fi
}

download_dotfiles () {
  echo "download_dotfiles"
  if [ ! -d "$DOTPATH" ];then
    git clone "$DOTFILES_GITHUB" "$DOTPATH"
  fi
}

deploy_dotfiles () {
  echo "deploy_dotfiles"
  . "$DOTPATH"/scripts/deploy.sh
}

install_homebrew () {
  echo "install_homebrew"
  . "$DOTPATH"/scripts/homebrew.sh
}

main () {
  if [ $PLATFORM != "Darwin" ]; then
    echo "Only MacOS supported"
    exit 1
  fi

  initialize
  make_workspace

  if [ -x "$(which curl)" ] || [ -x "$(which git)" ]; then
    download_dotfiles && deploy_dotfiles && install_homebrew
  else
    echo "Please install dependencies: ('git', 'curl')"
    exit 1
  fi
}

# main
deploy_dotfiles
