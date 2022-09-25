#!/bin/bash

PLATFORM=$(uname); export PLATFORM

if [ $PLATFORM = "Darwin" ]; then
    if [ ! which brew &> /dev/null ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi