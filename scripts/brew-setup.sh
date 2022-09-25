#!/bin/bash

# $1: Brewfile path

PLATFORM=$(uname); export PLATFORM

if [ $PLATFORM = "Darwin" ]; then
  brew bundle --file="${1}"
else
  echo "Only MacOS supported"
  exit 1
fi