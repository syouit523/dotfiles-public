# dotfiles-public

## インストール方法

```bash
xcode-select -p &>/dev/null || xcode-select --install
until xcode-select -p &>/dev/null; do sleep 5; done
bash <(curl -sL https://raw.githubusercontent.com/syouit523/dotfiles-public/main/scripts/init.sh)
```

> **Note**: 1行目で Xcode Command Line Tools がインストール済みかチェックし、未インストールならインストールダイアログを表示します。2行目で完了するまで待機してから、次のコマンド（init.sh）を実行します。Linux環境では1〜2行目はスキップしてください。

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
