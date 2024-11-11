#!/bin/bash

# $1: Operation mode (link, unlink, delete)
# $2: Root dir
MODE=$1
ROOT_DIR=$2
WORKSPACE="${HOME}/workspace"
CONFIGS="${ROOT_DIR}/configs"

if [[ -z "$MODE" || -z "$ROOT_DIR" ]]; then
  echo "Usage: $0 {link|unlink|delete} /path/to/root_dir"
  exit 1
fi

deploy_git () {
  case "$MODE" in
    link)
    ln -sf "$1"/gitignore_global ~/.gitignore_global
    cp "$1"/gitconfig ~/.gitconfig # copy it since modify user config after
    ## SET USER CONFIG INTO COMPANY DIR
    echo "DO YOU WANT TO SET COMPANY USER INFO?: y/n"
    read flag
    if [[ $flag = "y" || $flag = "Y" ]]; then
        echo "INPUT THE COMPANY NAME: "
        read company
        echo "CREATED THE COMPANY DIRECTORY INTO THE WORKSPACE"
        echo "INPUT YOUR COMPANY E-MAIL: "
        read mail_company
        echo "INPUT YOUR NAME: "
        read name_company

        COMPANY_CONFIG="${WORKSPACE}/${company}/.${company}.gitconfig"
        mkdir -p $WORKSPACE/${company}
        cat - << EOS >> ${COMPANY_CONFIG}
[user]
  email = ${mail_company}
  name = ${name_company}
EOS
        ### UPDATE UER CONFIG
        cat - << EOS >> ~/.gitconfig

#external
[includeIf "gitdir:${WORKSPACE}/${company}/"]
  path = ${COMPANY_CONFIG}
EOS
    fi
      ;;
    unlink)
      unlink ~/.gitignore_global
      # not linked .gitconfig
      ;;
    delete)
      rm -f "~/.gitconfig"
      rm -f "~/.gitignore_global"
      ;;
  esac
}

deploy_vim () {
  case "$MODE" in
    link)
      ln -sf "$1"/gvimrc ~/.gvimrc
      ln -sf "$1"/vimrc ~/.vimrc
      ;;
    unlink)
      unlink ~/.gvimrc
      unlink ~/.vimrc
      ;;
    delete)
      rm -f ~/.gvimrc
      rm -f ~/.vimrc
      ;;
  esac
}

deploy_zsh () {
  case "$MODE" in
    link)
      ln -sf "$1"/zshrc ~/.zshrc
      ln -sf "$1"/p10k.zsh ~/.p10k.zsh
      mkdir -p ~/.config/zsh/shoichi/
      sudo -n ln -sf "$1"/shoichi/* ~/.config/zsh/shoichi/
    ;;
    unlink)
      unlink ~/.zshrc
      unlink ~/.p10k.zsh
      unlink ~/.config/zsh/shoichi/
      ;;
    delete)
      rm -f ~/.zshrc
      rm -f ~/.p10k.zsh
      rm -rf ~/.config/zsh/
      ;;
  esac
}

deploy_fish () {
  case "$MODE" in
    link)
      sudo -n ln -sf "$1"/config/fish/* ~/.config/fish/
      ;;
    unlink)
      unlink ~/.config/fish/
      ;;
    delete)
      rm -rf ~/.config/fish/
      ;;
  esac
}

deploy_vscode () {
  case "$MODE" in
    link)
      sudo -n mkdir ~/Library/Application\ Support/Code/User/
      sudo -n ln -sf "$1"/settings.json ~/Library/Application\ Support/Code/User/
      ;;
    unlink)
      sudo -n unlink ~/Library/Application Support/Code/User/settings.json
      ;;
    delete)
      sudo rm -rf ~/Library/Application Support/Code/User/settings.json
      ;;
  esac
}

deploy_nvim () {
  target_dir="${HOME}/.config/nvim"
  case "$MODE" in
    link)
      mkdir -p ~/.config/nvim/
      source_dir=""$1""

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
      ;;
    unlink)
      # target_dir にあるシンボリックリンクを削除
      find "$target_dir" -type l | while read -r symlink; do
        unlink "$symlink"
      done
      ;;
    delete)
      # source_dir 内のすべてのファイルを削除
      find "$target_dir" -type f | while read -r file; do
        rm -f "$file"
      done
      ;;
  esac
}

for DIR_FULLPATH in $(find "$CONFIGS" -not -path '*/\.*' -mindepth 1 -maxdepth 1 -type d); do
  DIR_NAME=${DIR_FULLPATH##*/}
  echo "${MODE} ${DIR_NAME}"
  case "$DIR_NAME" in
    "git" ) deploy_git $DIR_FULLPATH;;
    "vim" ) deploy_vim $DIR_FULLPATH;;
    "zsh" ) deploy_zsh $DIR_FULLPATH;;
    "fish" ) deploy_fish $DIR_FULLPATH;;
    "vscode" ) deploy_vscode $DIR_FULLPATH;;
    "nvim" ) deploy_nvim $DIR_FULLPATH;;
  esac
done
