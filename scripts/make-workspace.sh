#!/bin/bash

make_workspace () {
    if [ ! -d ~/"$1" ]; then
        mkdir ~/"$1"
    fi
}

make_workspace "workspace"