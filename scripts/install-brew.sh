#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if command -v brew >/dev/null 2>&1; then
    sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
else
    echo "brew is already installed."
    echo "skip installing brew"
fi
