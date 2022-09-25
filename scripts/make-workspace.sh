#!/bin/bash

WORKSPACE_DIR_NAME="workspace"

make_workspace () {
    if [ ! -d ~/$1 ];then
        mkdir ~/$1
    fi

}

make_company () {
    if [ ! -d ~/$1/$2 ]; then
        mkdir ~/$1/$2
    fi
}

echo "DO YOU WANT TO MAKE WORKSPACE DIR?: [y/n] "
read flag
if [ $flag = y ]; then
    echo -n "ENTER COMPANY NAME: "
    read companyname
    make_workspace WORKSPACE_DIR_NAME
    make_company WORKSPACE_DIR_NAME companyname
fi