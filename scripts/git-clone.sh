#!/bin/bash

# 引数チェック
if [ $# -lt 1 ]; then
  echo "Usage: $0 <repository_url> [link_directory]"
  echo "link_directory is optional. If provided, a symbolic link will be created."
  echo "Example: $0 https://github.com/user/repo.git ~/.config/repo"
  exit 1
fi

# deps/ の作成場所を確定する。
#   - GIT_CLONE_BASE_DIR が指定されていればそこに cd（テスト等で活用）
#   - そうでなければスクリプト 1階層上 (= リポジトリルート) に cd
# これにより任意ディレクトリから sh 経由で呼ばれても deps/ が散らからない。
BASE_DIR="${GIT_CLONE_BASE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$BASE_DIR" || exit 1

REPO_URL=$1
# リポジトリ名をURLから抽出 (https://.../repo.git や git@...:repo.git からrepoを抽出)
REPO_NAME=$(basename "$REPO_URL" .git | sed 's/.*[:/]//')
LINK_DIR=$2

# depsディレクトリ作成
mkdir -p deps
chmod 755 deps

# 既存ディレクトリを削除（過去に sudo 経由で実行され root 所有になっている
# 可能性があるため、通常削除に失敗したら sudo にフォールバック）
if [ -e "deps/$REPO_NAME" ] || [ -L "deps/$REPO_NAME" ]; then
  if ! rm -rf "deps/$REPO_NAME" 2>/dev/null; then
    echo "Removing root-owned deps/$REPO_NAME with sudo..."
    sudo -n rm -rf "deps/$REPO_NAME" || {
      echo "Failed to remove deps/$REPO_NAME (sudo not available)"
      exit 1
    }
  fi
fi

echo "Cloning $REPO_URL into deps/$REPO_NAME..."
if ! git clone "$REPO_URL" "deps/$REPO_NAME" --depth 1; then
  echo "Failed to clone repository"
  exit 1
fi

# シンボリックリンク作成
if [ -n "$LINK_DIR" ]; then
  echo "Creating symbolic link from deps/$REPO_NAME to $LINK_DIR"
  mkdir -p "$(dirname "$LINK_DIR")"
  if ln -sf "$(pwd)/deps/$REPO_NAME" "$LINK_DIR"; then
    echo "Successfully created symbolic link"
  else
    echo "Failed to create symbolic link"
    exit 1
  fi
fi

CLONED_DIR_PATH="$(pwd)/deps/$REPO_NAME"
export CLONED_DIR_PATH
echo "Operation completed successfully"
echo "Cloned repository path: $CLONED_DIR_PATH"

if [ -n "$LINK_DIR" ]; then
  echo "Symbolic link created at: $LINK_DIR"
fi
