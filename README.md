# dotfiles-public

## インストール方法

```bash
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
- `make test` または `make t`: ローカル環境でテストを実行
  - 初回実行時は自動的にBATSテストフレームワークをインストールします
  - 主要なシェルスクリプトの機能をテストします
  - テスト対象:
    - `deploy-configs.sh`: ファイルのリンク/コピー/削除機能
    - `git-clone.sh`: リポジトリクローンとシンボリックリンク作成
    - `setup-gitconfig.sh`: Git設定のセットアップ
- `make docker-test` または `make dt`: Docker（Ubuntu環境）でテストを実行
  - GitHub ActionsのCI環境をローカルで再現します
  - Dockerが必要です
- `make docker-build`: Dockerテストイメージをビルド
- `make test-clean`: テストアーティファクトをクリーンアップ

### その他
- `make font` または `make f`: フォントのインストール
- `make ssh-key-gen`: SSHキーを生成
- `make linux_setup`: Linux用GUIアプリケーションのセットアップ
- `make clean` または `make c`: 環境をクリーンアップ（Homebrew、dotfiles、シェルの設定を削除）

## 開発

### テストの実行

このリポジトリには、主要なシェルスクリプトの動作を検証するためのテストが含まれています。

#### ローカル環境でのテスト

```bash
# すべてのテストを実行
make test

# または直接テストランナーを実行
./tests/run-tests.sh
```

テストフレームワークには [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core) を使用しています。初回実行時は自動的にインストールされます。

#### Docker環境でのテスト

GitHub ActionsのCI環境（Ubuntu）をローカルで再現してテストできます：

```bash
# Dockerでテストを実行（推奨）
make docker-test

# または直接スクリプトを実行
./tests/docker/docker-test.sh
```

**前提条件**: Dockerがインストールされていること

Dockerテストでは以下が実行されます：
- BATSテストスイート
- ShellCheckによる静的解析

詳細は [`tests/docker/README.md`](tests/docker/README.md) を参照してください。

### CI/CD

このリポジトリではGitHub Actionsによる自動テストが設定されています。

#### 自動実行タイミング
- `main` ブランチへのプッシュ時
- `claude/**` ブランチへのプッシュ時
- `main` ブランチへのプルリクエスト時
- 手動実行（workflow_dispatch）

#### テスト内容
1. **BATSテスト** (Ubuntu & macOS)
   - すべてのテストケースを実行
   - テスト結果をアーティファクトとして保存（7日間）

2. **ShellCheck静的解析** (Ubuntu)
   - 全シェルスクリプトの静的解析
   - スクリプトの実行権限チェック

#### ローカルでCI環境を再現
```bash
# Docker環境でテストを実行（Ubuntu環境を再現）
make docker-test
```
