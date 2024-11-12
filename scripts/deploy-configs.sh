#!/bin/bash

# $1: Operation mode (link, copy, delete)
# $2: Root dir
MODE=$1
ROOT_DIR=$2
WORKSPACE="${HOME}/workspace"
CONFIGS="${ROOT_DIR}/configs"

if [[ -z "$MODE" || -z "$ROOT_DIR" ]]; then
  echo "Usage: $0 {link|copy|delete} /path/to/root_dir"
  exit 1
fi

mode_file() {
  local source_file="$1"
  local target_file="$2"
  local backup_suffix=".backup"
   case "$MODE" in
    link)
      mkdir -p "$(dirname "$target_file")"
      if [[ ! -e "$target_file" ]]; then
        # ターゲットファイルが存在しない場合、リンクを作成
        ln -sf "$source_file" "$target_file"
      elif [[ -L "$target_file" ]]; then
        # ターゲットがシンボリックリンクの場合のみ、readlinkを使用
        if [[ "$(readlink -f "$target_file")" == "$(realpath "$source_file")" ]]; then
          echo "already linked: $target_file"
        else
          ln -sf -b --suffix="${backup_suffix}" "$source_file" "$target_file"
        fi
      else
        # ターゲットファイルが存在する場合、バックアップを作成してリンク
        ln -sf -b --suffix="${backup_suffix}" "$source_file" "$target_file"
      fi
      ;;
    copy)
      mkdir -p "$(dirname "$target_file")"
      if [[ -e "${target_file}${backup_suffix}" ]]; then
        # backup file is already exists
        cp -b --suffix="$backup_suffix" "$source_file" "$target_file"
      else
        # copy source file to target file and create backup file
        cp -b --suffix="$backup_suffix" "$source_file" "$target_file"
      fi
      ;;
    delete)
      echo "delete: $target_file"
      sudo -n rm -rf "$target_file"
      if [[ -f "${target_file}${backup_suffix}" ]]; then
        # restore backup file
        sudo -n mv "${target_file}${backup_suffix}" "$target_file"
      fi
      ;;
  esac
}


mode_directory() {
    local source_dir="$1"
    local target_dir="$2"
    find "$source_dir" -mindepth 1 -type f | while read -r source_path; do
        local relative_path="${source_path#$source_dir/}"
        local target_path="$target_dir/$relative_path"
        
        mode_file "$source_path" "$target_path"
    done
}

deploy_git () {
    mode_file "$1/gitignore_global" "${HOME}/.gitignore_global"
    case "$MODE" in
    link|copy)
        cp --remove-destination "$1/gitconfig" ~/.gitconfig # copy it since modify user config after
        ## SET USER CONFIG INTO COMPANY DIR
        echo "DO YOU WANT TO SET COMPANY USER INFO?: y/n"
        read -r flag
        if [[ "$flag" == "y" || "$flag" == "Y" ]]; then
            echo "INPUT THE COMPANY NAME: "
            read -r company
            echo "CREATED THE COMPANY DIRECTORY INTO THE WORKSPACE"
            echo "INPUT YOUR COMPANY E-MAIL: "
            read -r mail_company
            echo "INPUT YOUR NAME: "
            read -r name_company

            COMPANY_CONFIG="${WORKSPACE}/${company}/.${company}.gitconfig"
            mkdir -p "$WORKSPACE/${company}"
            cat << EOS >> "${COMPANY_CONFIG}"
[user]
  email = ${mail_company}
  name = ${name_company}
EOS
            ### UPDATE USER CONFIG
            cat << EOS >> ~/.gitconfig

#external
[includeIf "gitdir:${WORKSPACE}/${company}/"]
  path = ${COMPANY_CONFIG}
EOS
        fi
        ;;
    delete)
        sudo -n rm -rf ~/.gitconfig
        ;;
    *)
        echo "Invalid mode: $MODE"
        ;;
    esac
}

deploy_vim () {
  mode_file "$1/gvimrc" "${HOME}/.gvimrc"
  mode_file "$1/vimrc" "${HOME}/.vimrc"
}

deploy_zsh () {
      mode_file "$1/zshrc" "${HOME}/.zshrc"
      mode_file "$1/p10k.zsh" "${HOME}/.p10k.zsh"
      mkdir -p ~/.config/zsh/shoichi/
      mode_directory "$1/shoichi" "${HOME}/.config/zsh/shoichi"
}

deploy_fish () {
  mode_directory "$1/config/fish" "${HOME}/.config/fish"
}

deploy_vscode () {
      local vscode_dir="${HOME}/Library/Application Support/Code/User"
      sudo -n mode_file "$1/settings.json" "$vscode_dir/settings.json"
}

deploy_nvim () {
  mode_directory "$1" "${HOME}/.config/nvim"
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
    * ) echo "No deployment function for ${DIR_NAME}";;
  esac
done
