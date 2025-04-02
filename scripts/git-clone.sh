#!/bin/bash

# 引数チェック
if [ $# -lt 1 ]; then
  echo "Usage: $0 <repository_url> [link_directory]"
  echo "link_directory is optional. If provided, a symbolic link will be created."
  echo "Example: $0 https://github.com/user/repo.git ~/.config/repo"
  exit 1
fi

REPO_URL=$1
# リポジトリ名をURLから抽出 (https://.../repo.git や git@...:repo.git からrepoを抽出)
REPO_NAME=$(basename "$REPO_URL" .git | sed 's/.*[:/]//')
LINK_DIR=$2

# depsディレクトリ作成
mkdir -p deps
chmod 775 deps

# リポジトリクローン
echo "Cloning $REPO_URL into deps/$REPO_NAME..."
git clone "$REPO_URL" "deps/$REPO_NAME" --depth 1

if [ $? -ne 0 ]; then
  echo "Failed to clone repository"
  exit 1
fi

# シンボリックリンク作成
if [ -n "$LINK_DIR" ]; then
  echo "Creating symbolic link from deps/$REPO_NAME to $LINK_DIR"
  mkdir -p "$(dirname "$LINK_DIR")"
  ln -sf "$(pwd)/deps/$REPO_NAME" "$LINK_DIR"
  
  if [ $? -eq 0 ]; then
    echo "Successfully created symbolic link"
  else
    echo "Failed to create symbolic link"
    exit 1
  fi
fi

export CLONED_DIR_PATH="$(pwd)/deps/$REPO_NAME"
echo "Operation completed successfully"
echo "Cloned repository path: $CLONED_DIR_PATH"

if [ -n "$LINK_DIR" ]; then
  echo "Symbolic link created at: $LINK_DIR"
fi
