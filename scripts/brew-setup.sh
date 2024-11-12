#!/bin/bash

# $1: Brewfile path
sudo -v
sudo -n brew bundle --file="${1}"