#!/bin/bash

PLATFORM=$(uname); export PLATFORM

install_homebrew () {
  if [ $PLATFORM = "Darwin" ]; then
    if [ ! which brew &> /dev/null ]; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  fi
}

MULTIPLATFORM_PACKAGES="${DOTPATH}/packages/homebrew/multiplatform_packages.txt" # Linux and MacOS packages
DARWIN_PACKAGES="${DOTPATH}/packages/homebrew/macos.txt" # Only MacOS packages

install_homebrew_packages () {
  if [ $PLATFORM = "Darwin" ]; then
  brew bundle --file="${DOTPATH}/Brewfile"
else
  echo "Only MacOS supported"
  exit 1
fi
}

install_homebrew
install_homebrew_packages