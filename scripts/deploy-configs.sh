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
    ln -sf "$1"/p10k.zsh ~/.p10k.zsh
    mkdir -p ~/.config/zsh/shoichi/
    sudo -n ln -sf "$1"/shoichi/* ~/.config/zsh/shoichi/
}

deploy_fish () {
    sudo -n ln -sf "$1"/config/fish/* ~/.config/fish/
}

deploy_vscode () {
  sudo -n mkdir ~/Library/Application\ Support/Code/User/
  sudo -n ln -sf "$1"/settings.json ~/Library/Application\ Support/Code/User/
}

deploy_nvim () {
    mkdir -p ~/.config/nvim/

  source_dir=""$1""
  target_dir="${HOME}/.config/nvim"

  # target_dir に source_dir 内のすべてのファイルのシンボリックリンクを作成
  find "$source_dir" -type f | while read -r file; do
    # リンク先のパスを生成
    link_path="$target_dir/${file#$source_dir/}"
    # 必要なディレクトリを作成
    mkdir -p "$(dirname "$link_path")"
  # シンボリックリンクを作成
    [ ! -e "$link_path" ] || rm "$link_path"  # 既存のリンクを削除
    ln -sf "$file" "$link_path"
  done
}

for DIR_FULLPATH in $(find "$CONFIGS" -not -path '*/\.*' -mindepth 1 -maxdepth 1 -type d); do
  DIR_NAME=${DIR_FULLPATH##*/}
  echo "deploying ${DIR_NAME}"
  case "$DIR_NAME" in
    "git" ) deploy_git $DIR_FULLPATH;;
    "vim" ) deploy_vim $DIR_FULLPATH;;
    "zsh" ) deploy_zsh $DIR_FULLPATH;;
    "fish" ) deploy_fish $DIR_FULLPATH;;
    "vscode" ) deploy_vscode $DIR_FULLPATH;;
    "nvim" ) deploy_nvim $DIR_FULLPATH;;
  esac
done
