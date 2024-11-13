#!/bin/bash

WORKSPACE_DIR_NAME="workspace"

make_workspace () {
    if [ ! -d ~/$1 ];then
        mkdir ~/$1
    fi

}

make_workspace WORKSPACE_DIR_NAME