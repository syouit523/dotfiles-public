#!/bin/bash

if [ ! -x "$(which xcode-select -p)" ]; then
    xcode-select install
fi