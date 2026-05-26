# dotfiles-public

## インストール方法

### macOS（ワンライナー、対話なし）

```bash
xcode-select -p &>/dev/null || xcode-select --install; \
until xcode-select -p &>/dev/null; do sleep 5; done; \
sudo -v && ( while true; do sudo -n true; sleep 50; done ) >/dev/null 2>&1 & \
NONINTERACTIVE=1 \
BOOTSTRAP_MODE=minimum \
GIT_USER_NAME="Shoichi Taguchi" \
GIT_USER_EMAIL="taguchi@shoichi.me" \
DEFAULT_SHELL=zsh \
bash <(curl -sL https://raw.githubusercontent.com/syouit523/dotfiles-public/main/scripts/init.sh)
```

実行すると最初に **1回だけ sudo パスワードを聞かれます**。それ以降は全自動で完了します。

#### 環境変数の一覧

| 変数 | 用途 | 例 |
|------|------|------|
| `NONINTERACTIVE` | `1` を渡すとすべての対話プロンプトをスキップ | `1` |
| `BOOTSTRAP_MODE` | インストールするパッケージの範囲 | `minimum` / `extra` |
| `GIT_USER_NAME` | git の user.name | `"Shoichi Taguchi"` |
| `GIT_USER_EMAIL` | git の user.email | `"taguchi@shoichi.me"` |
| `DEFAULT_SHELL` | デフォルトシェル（`/etc/shells` から検索） | `zsh` / `fish` |

#### bootstrap 後の手動ステップ

SSH キー生成と GitHub 認証は対話が必要なため、bootstrap には含めていません。完了後に手動で:

```bash
cd ~/workspace/dotfiles-public && make ssh-key-gen
```

### 対話モード（従来）

環境変数を渡さない場合は対話モードで実行されます:

```bash
xcode-select -p &>/dev/null || xcode-select --install
until xcode-select -p &>/dev/null; do sleep 5; done
bash <(curl -sL https://raw.githubusercontent.com/syouit523/dotfiles-public/main/scripts/init.sh)
```

## 利用可能なコマンド

### 基本セットアップ
- `make bootstrap` または `make b`: 環境に応じた基本セットアップを実行
  - macOS: Homebrew、Zsh、dotfilesのセットアップ
  - Linux: Homebrew、Zsh、フォント、dotfiles、Flatpakのセットアップ
  - Windows: 未対応

### Homebrew関連
- `make brew_install`: Homebrewをインストール
- `make brew_setup`: Brewfileからパッケージをインストール
- `make brew_mac_app`: macOS専用アプリをApp Storeからインストール
- `make brew_update_all`: Homebrewとパッケージを更新

### シェル設定
- `make zsh`: Zshのセットアップ
- `make zsh_extensions`: Zsh拡張機能のインストール
- `make fish`: Fishシェルのセットアップ
- `make reload_zshrc`: .zshrcを再読み込み

### dotfiles管理
- `make link` または `make l`: dotfilesのシンボリックリンクを作成
- `make copy`: dotfilesをコピー
- `make delete`: dotfilesを削除

### Tmux
- `make tmux`: tmuxとTPM（Tmux Plugin Manager）のセットアップ
  - **初回のみ**: プラグインを有効化するため、以下の手順を実行してください
    1. `tmux` でセッションを開始
    2. `Ctrl+Space` + `I` (大文字のI) を押してプラグインをインストール
    3. "TMUX environment reloaded" のメッセージが表示されたら完了
  - **利用可能な機能**:
    - `Ctrl+H/J/K/L`: tmuxペイン間の移動（vim/neovimとシームレスに連携）
    - セッションの自動保存・復元（tmux-resurrect/continuum）
    - CPU/メモリ使用率の表示（ステータスバー左側）

### テスト
- `make test` または `make t`: すべてのテストを実行
  - 初回実行時は自動的にBATSテストフレームワークをインストールします
  - 主要なシェルスクリプトの機能をテストします
  - テスト対象:
    - `deploy-configs.sh`: ファイルのリンク/コピー/削除機能
    - `git-clone.sh`: リポジトリクローンとシンボリックリンク作成
    - `setup-gitconfig.sh`: Git設定のセットアップ

### その他
- `make font` または `make f`: フォントのインストール
- `make ssh-key-gen`: SSHキーを生成
- `make linux_setup`: Linux用GUIアプリケーションのセットアップ
- `make clean` または `make c`: 環境をクリーンアップ（Homebrew、dotfiles、シェルの設定を削除）

## 開発

### テストの実行

このリポジトリには、主要なシェルスクリプトの動作を検証するためのテストが含まれています。

```bash
# すべてのテストを実行
make test

# または直接テストランナーを実行
./tests/run-tests.sh
```

テストフレームワークには [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core) を使用しています。初回実行時は自動的にインストールされます。

### CI/CD

GitHub Actionsワークフローのテンプレートが用意されています。セットアップ方法：

```bash
# ワークフローディレクトリを作成
mkdir -p .github/workflows

# テンプレートをコピー
cp tests/ci-templates/github-actions-test.yml .github/workflows/test.yml

# コミット＆プッシュ
git add .github/workflows/test.yml
git commit -m "Add GitHub Actions workflow"
git push
```

ワークフローの機能：
- テストはUbuntuとmacOSの両方の環境で実行されます
- ShellCheckによる静的解析も実行されます
- プッシュ、プルリクエスト、または手動で実行可能

詳細は [`tests/ci-templates/README.md`](tests/ci-templates/README.md) を参照してください。
