#!/bin/bash

# $1: Operation mode (link, copy, delete)
# $2: Root dir
MODE=$1
ROOT_DIR=$2
WORKSPACE="${HOME}/workspace"
CONFIGS="${ROOT_DIR}/configs"

OS="$(uname -s)"

if [ -z "$MODE" ] || [ -z "$ROOT_DIR" ]; then
  echo "Usage: $0 {link|copy|delete} /path/to/root_dir"
  exit 1
fi

# Back up a file before overwriting. Uses a fixed `.backup` name to keep
# delete-mode restore deterministic, but never overwrites an existing backup —
# subsequent re-runs add a timestamped suffix to preserve the original.
#
# If the target is already a symlink pointing into this dotfiles repo
# (ROOT_DIR), skip the backup: it's just a leftover from a previous link,
# not user data worth preserving.
backup_file() {
  local target_file="$1"
  local target_dir
  target_dir="$(dirname "$target_file")"
  local base
  base="$(basename "$target_file")"
  local backup_path="${target_dir}/${base}.backup"

  if [ -L "$target_file" ]; then
    local link_target
    link_target="$(readlink "$target_file" 2>/dev/null || true)"
    case "$link_target" in
      "$ROOT_DIR"/*)
        # 既に dotfiles-public 配下を指す symlink。バックアップ不要。
        return 0
        ;;
    esac
  fi

  if [ ! -e "$backup_path" ] && [ ! -L "$backup_path" ]; then
    mv "$target_file" "$backup_path"
    echo "backup: $target_file -> $backup_path"
  else
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    local ts_backup="${target_dir}/${base}.backup.${ts}"
    mv "$target_file" "$ts_backup"
    echo "backup: $target_file -> $ts_backup (existing .backup preserved)"
  fi
}

mode_file() {
  local source_file="$1"
  local target_file="$2"
  local target_dir
  target_dir="$(dirname "$target_file")"
  local backup_path
  backup_path="${target_dir}/$(basename "$target_file").backup"

   case "$MODE" in
    link)
      if [ ! -e "$target_file" ] && [ ! -L "$target_file" ]; then
        ln -sf "$source_file" "$target_file"
      elif [ -L "$target_file" ] && [ "$(realpath "$target_file" 2>/dev/null)" = "$(realpath "$source_file")" ]; then
        echo "already linked: $target_file"
      else
        backup_file "$target_file"
        ln -sf "$source_file" "$target_file"
      fi
      ;;
    copy)
      mkdir -p "$target_dir"
      # link → copy の順に実行された場合、ターゲットが repo 内ソースを指す
      # symlink のまま残る（backup_file は ROOT_DIR 向き symlink を待避しない）。
      # そのまま cp すると symlink 越しにソースファイル自体へ書き込むため、
      # 先に symlink を削除する。
      if [ -L "$target_file" ]; then
        case "$(readlink "$target_file" 2>/dev/null)" in
          "$ROOT_DIR"/*) rm -f "$target_file" ;;
        esac
      fi
      if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        backup_file "$target_file"
      fi
      cp "$source_file" "$target_file"
      ;;
    delete)
      if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        rm -f "$target_file"
        if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
          echo "restore: $backup_path -> $target_file"
          mv "$backup_path" "$target_file"
        else
          # .backup が無い場合、最古のタイムスタンプ付きバックアップを復元
          local oldest_ts_backup
          oldest_ts_backup=$(ls -1 "${target_dir}/$(basename "$target_file").backup."* 2>/dev/null | sort | head -n 1 || true)
          if [ -n "$oldest_ts_backup" ] && [ -e "$oldest_ts_backup" ]; then
            echo "restore (oldest timestamped): $oldest_ts_backup -> $target_file"
            mv "$oldest_ts_backup" "$target_file"
          fi
        fi
      else
        echo "file not found: $target_file"
      fi
      ;;
  esac
}


mode_directory() {
    local source_dir="$1"
    local target_dir="$2"
    
    # ターゲットディレクトリが存在しない場合は作成
    mkdir -p "$target_dir"
    
    # パスを正規化（realpathの前にディレクトリが存在することを確認）
    source_dir="$(realpath "$source_dir")"
    target_dir="$(realpath "$target_dir")"
    
    echo "Processing directory:"
    echo "  Source: $source_dir"
    echo "  Target: $target_dir"
    
    # すべてのファイルを再帰的に処理
    # find ... | while だと将来 mode_file 内で read を使った時に
    # 同じ stdin パイプ食いが起きるため、配列で受けて while-read-here-string にする。
    local source_files
    source_files=$(find "$source_dir" -type f 2>/dev/null)
    [ -z "$source_files" ] && return 0
    while IFS= read -r source_path; do
        [ -z "$source_path" ] && continue
        # 相対パスを計算
        local rel_path="${source_path#"$source_dir"/}"
        local target_path="$target_dir/$rel_path"

        # ターゲットディレクトリを作成
        mkdir -p "$(dirname "$target_path")"

        echo "Linking:"
        echo "  From: $source_path"
        echo "  To: $target_path"

        mode_file "$source_path" "$target_path"
    done <<< "$source_files"
}

deploy_git () {
    mode_file "$1/gitignore_global" "${HOME}/.gitignore_global"
    case "$MODE" in
    link|copy)
        # ~/.gitconfig は git config --global で書き換えるためコピー必須。
        # 既存ファイルがある場合はバックアップを取ってから上書き。
        if [ -e ~/.gitconfig ] || [ -L ~/.gitconfig ]; then
            backup_file ~/.gitconfig
        fi
        cp "$1/gitconfig" ~/.gitconfig
        git config --global core.excludesfile ~/.gitignore_global
        ## SET USER CONFIG INTO COMPANY DIR
        # 注意: ここの read は **必ず /dev/tty から読む**。
        # deploy-configs.sh は呼び出し側で `find ... | while read` または
        # `<<< "$..."` 経由のループ内で source / 実行されることがあり、
        # そのままだと read が次のループエントリを消費して
        # configs/karabiner などが飛ばされる事故が起きる。
        if [ "$NONINTERACTIVE" = "1" ]; then
            flag="n"
            echo "NONINTERACTIVE: skipping company user info setup"
        elif [ -e /dev/tty ]; then
            echo "DO YOU WANT TO SET COMPANY USER INFO?: y/n"
            read -r flag </dev/tty
        else
            flag="n"
            echo "No TTY: skipping company user info setup"
        fi
        if [ "$flag" = "y" ] || [ "$flag" = "Y" ]; then
            echo "INPUT THE COMPANY NAME: "
            read -r company </dev/tty
            echo "CREATED THE COMPANY DIRECTORY INTO THE WORKSPACE"
            echo "INPUT YOUR COMPANY E-MAIL: "
            read -r mail_company </dev/tty
            echo "INPUT YOUR NAME: "
            read -r name_company </dev/tty

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
        # ~/.gitconfig は deploy_git の link/copy でコピーされる扱い。
        # backup_file で待避した .backup があれば復元する。
        if [ -e ~/.gitconfig ] || [ -L ~/.gitconfig ]; then
            rm -f ~/.gitconfig
        fi
        if [ -e ~/.gitconfig.backup ]; then
            echo "restore: ~/.gitconfig.backup -> ~/.gitconfig"
            mv ~/.gitconfig.backup ~/.gitconfig
        fi
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
  if [ "$OS" = "Darwin" ]; then
      local vscode_dir="${HOME}/Library/Application Support/Code/User"
      # VS Code を起動したことがない場合ディレクトリが存在しないので作成
      mkdir -p "$vscode_dir"
      mode_file "$1/settings.json" "$vscode_dir/settings.json"
  fi
}

deploy_iterm2 () {
  if [ "$OS" = "Darwin" ]; then
      # iTerm2 の plist は ~/Library/Preferences/ に置く
      local prefs_dir="${HOME}/Library/Preferences"
      mkdir -p "$prefs_dir"
      mode_file "$1/com.googlecode.iterm2.plist" "$prefs_dir/com.googlecode.iterm2.plist"
  fi
}

deploy_nvim () {
  mode_directory "$1" "${HOME}/.config/nvim"
}

deploy_karabiner () {
  mode_directory "$1" "${HOME}/.config/karabiner"
}

deploy_wezterm () {
  mode_directory "$1" "${HOME}/.config/wezterm"
}

deploy_tmux () {
  mode_file "$1/tmux.conf" "${HOME}/.tmux.conf"
}

deploy_starship () {
  mode_directory "$1" "${HOME}/.config/starship"
}

deploy_ghostty () {
  mode_directory "$1" "${HOME}/.config/ghostty"
}

## Deploy bin scripts to ~/.local/bin
deploy_bin() {
    local bin_dir="$ROOT_DIR/bin"
    local target_dir="$HOME/.local/bin"
    if [ ! -d "$bin_dir" ]; then
        return 0
    fi
    mkdir -p "$target_dir"
    local scripts
    scripts=$(find "$bin_dir" -type f 2>/dev/null)
    [ -z "$scripts" ] && return 0
    while IFS= read -r script; do
        [ -z "$script" ] && continue
        local name
        name="$(basename "$script")"
        mode_file "$script" "$target_dir/$name"
    done <<< "$scripts"
}

echo "${MODE} bin"
deploy_bin

# find の結果を一旦変数に取り込んでからループする。
# `find ... | while read` 形式だと deploy_git 内の `read -r flag` などが
# パイプ stdin から find の次の行を消費してしまい、特定のディレクトリが
# 飛ばされる事故が起きる（過去に karabiner が deploy_git の prompt に
# 食われてスキップされた）。
CONFIG_DIRS=$(find "$CONFIGS" -not -path '*/\.*' -mindepth 1 -maxdepth 1 -type d)
while IFS= read -r DIR_FULLPATH; do
  [ -z "$DIR_FULLPATH" ] && continue
  DIR_NAME=${DIR_FULLPATH##*/}
  echo "${MODE} ${DIR_NAME}"
  case "$DIR_NAME" in
    "git" ) deploy_git "$DIR_FULLPATH";;
    "vim" ) deploy_vim "$DIR_FULLPATH";;
    "zsh" ) deploy_zsh "$DIR_FULLPATH";;
    "fish" ) deploy_fish "$DIR_FULLPATH";;
    "vscode" ) deploy_vscode "$DIR_FULLPATH";;
    "iterm2" ) deploy_iterm2 "$DIR_FULLPATH";;
    "nvim" ) deploy_nvim "$DIR_FULLPATH";;
    "karabiner" ) deploy_karabiner "$DIR_FULLPATH";;
    "wezterm" ) deploy_wezterm "$DIR_FULLPATH";;
    "tmux" ) deploy_tmux "$DIR_FULLPATH";;
    "starship" ) deploy_starship "$DIR_FULLPATH";;
    "ghostty" ) deploy_ghostty "$DIR_FULLPATH";;
    * ) echo "No deployment function for ${DIR_NAME}";;
  esac
done <<< "$CONFIG_DIRS"
