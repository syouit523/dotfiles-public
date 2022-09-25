#!/bin/bash

# $1: Root dir
WORKSPACE="${HOME}/workspace"
CONFIGS=${1}/configs

deploy_git () {
    ln -sf "$1"/gitignore_global ~/.gitignore_global
    cp "$1"/gitconfig ~/.gitconfig
    ### SET USER CONFIG
    echo "INPUT YOUR E-MAIL: "
    read mail
    echo "INPUT YOUR NAME: "
    read name
    cat - << EOS >> ~/.gitconfig

[user]
  email = ${mail}
  name = ${name}
EOS
    ## SET USER CONFIG INTO COMPANY DIR
    echo "DO YOU WANT TO SET COMPANY USER INFO?: y/n"
    read flag
    if [ $flag = "y" ]; then
        echo "INPUT DIR NAME INTO WORKSPACE: "
        read dir
        echo "INPUT YOUR COMPANY E-MAIL: "
        read mail_company
        echo "INPUT YOUR NAME: "
        read name_company
        COMPANY_CONFIG="${WORKSPACE}/${dir}/.${dir}.gitconfig"
        cat - << EOS >> ${COMPANY_CONFIG}
[user]
  email = ${mail_company}
  name = ${name_company}
EOS
        ### UPDATE UER CONFIG
        cat - << EOS >> ~/.gitconfig

#external
[includeIf "gitdir:${WORKSPACE}/${dir}/"]
  path = ${COMPANY_CONFIG}
EOS
    fi
}

deploy_vim () {
    ln -sf "$1"/gvimrc ~/.gvimrc
    ln -sf "$1"/vimrc ~/.vimrc
}

deploy_zsh () {
    ln -sf "$1"/zshrc ~/.zshrc
}

deploy_fish () {
    ln -sf "$1"/config/fish/* ~/.config/fish/
}

for DIR_FULLPATH in $(find "$CONFIGS" -not -path '*/\.*' -mindepth 1 -maxdepth 1 -type d); do
  DIR_NAME=${DIR_FULLPATH##*/}
  echo "deploying ${DIR_NAME}"
  case "$DIR_NAME" in
    "git" ) deploy_git $DIR_FULLPATH;;
    "vim" ) deploy_vim $DIR_FULLPATH;;
    "zsh" ) deploy_zsh $DIR_FULLPATH;;
    "fish" ) deploy_fish $DIR_FULLPATH;;
  esac
done