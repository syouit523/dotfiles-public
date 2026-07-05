# dotfiles-public

> 📚 各ツールの操作方法・キーバインド・プラグインの使い方は **[docs/](docs/README.md)** を参照してください(tmux / zsh / fish / Neovim / git / ターミナル)。

## ⚠️ Breaking Changes

- **`make bootstrap` から `make ssh-key-gen` を除外**しました。SSH キー生成と `gh auth login` は対話が必須なため、bootstrap 後に手動で `make ssh-key-gen` を実行してください。
- 非対話モードの環境変数は `DOTFILES_` プレフィックス付きです（`GIT_USER_NAME` などのジェネリックな名前はユーザー環境と衝突するため避けています）。

## インストール方法

### macOS（ワンライナー、対話なし）

```bash
xcode-select -p &>/dev/null || xcode-select --install
until xcode-select -p &>/dev/null; do sleep 5; done
NONINTERACTIVE=1 \
DOTFILES_BOOTSTRAP_MODE=minimum \
DOTFILES_GIT_USER_NAME="Your Name" \
DOTFILES_GIT_USER_EMAIL="you@example.com" \
DOTFILES_DEFAULT_SHELL=zsh \
bash <(curl -sL https://raw.githubusercontent.com/syouit523/dotfiles-public/main/scripts/init.sh)
```

実行中に **1回だけ sudo パスワードを聞かれます**（Makefile の `check-sudo` が cache + keep-alive を担当）。それ以降は全自動で完了します。

> **Security note**: 環境変数を直接コマンドラインに書くとシェル履歴・`ps` 出力に残ります。気になる場合は行頭にスペースを置くか（`HISTCONTROL=ignorespace` 設定時）、別ファイルに `export` して `source` してください。

#### 環境変数の一覧

| 変数 | 用途 | 例 |
|------|------|------|
| `NONINTERACTIVE` | `1` を渡すとすべての対話プロンプトをスキップ | `1` |
| `DOTFILES_BOOTSTRAP_MODE` | インストールするパッケージの範囲（内部的に Makefile の `MODE` にマップ） | `minimum` / `extra` |
| `DOTFILES_GIT_USER_NAME` | git の user.name | `"Your Name"` |
| `DOTFILES_GIT_USER_EMAIL` | git の user.email | `"you@example.com"` |
| `DOTFILES_DEFAULT_SHELL` | デフォルトシェル（`/etc/shells` から検索、フルパスも可） | `zsh` / `fish` / `/bin/zsh` |

#### bootstrap 後の手動ステップ

##### 1. SSH 鍵生成 + GitHub 認証

SSH キー生成と GitHub 認証（`gh auth login`）は対話が必要なため、bootstrap には含めていません。完了後に手動で:

```bash
cd ~/workspace/dotfiles-public && make ssh-key-gen
```

> このコマンドは、リポジトリの origin が HTTPS だった場合に **自動で SSH に切り替え** ます（`git pull` が PAT 無しで通るようになる）。SSH 鍵が既にある環境でも、origin URL の書き換えは実行されます。

##### 2. SwiftLint (iOS 開発)

`swiftlint` は **Xcode.app の完全インストールが必須** で、Xcode CLT だけでは導入できないため bootstrap から除外しています。App Store で Xcode をインストールした後に:

```bash
brew install swiftlint
# または mint 経由
mint install realm/SwiftLint
```

##### 3. Ghostty のフォント

`configs/ghostty/config` は `Hack Nerd Font Mono` を使用します。bootstrap で `font-hack-nerd-font` cask が自動インストールされますが、**プロンプトアイコンが `?` に化ける場合** は Ghostty を完全に再起動してください（fontキャッシュの再読み込み）。

### Linux / Ubuntu（ワンライナー、対話なし）

```bash
NONINTERACTIVE=1 \
DOTFILES_BOOTSTRAP_MODE=minimum \
DOTFILES_GIT_USER_NAME="Your Name" \
DOTFILES_GIT_USER_EMAIL="you@example.com" \
DOTFILES_DEFAULT_SHELL=zsh \
bash <(curl -sL https://raw.githubusercontent.com/syouit523/dotfiles-public/main/scripts/init.sh)
```

- 対応ディストリビューション: **Ubuntu**（apt ベース。日本語ロケール設定は Ubuntu 専用）
- `git` / `make` / `curl` が無い素の環境でも、`init.sh` が最初に apt でインストールします
- CLI ツールは **Homebrew on Linux** で導入します。apt 版では古すぎるツール（neovim 0.11+、fzf 0.48+ が必要）を macOS と同じ Brewfile で最新に揃えるためです。macOS 専用の cask / iOS 系ツールは Brewfile 内の `OS.mac?` 分岐で自動スキップされます
- GUI アプリ（Flatpak 経由の WezTerm など）は含まれません。必要なら別途 `make linux_gui_setup` を実行してください
- 動作は GitHub Actions（Linux Bootstrap Test）で Ubuntu 実機相当を使って検証しています

### 対話モード（従来）

環境変数を渡さない場合は対話モードで実行されます:

```bash
xcode-select -p &>/dev/null || xcode-select --install
until xcode-select -p &>/dev/null; do sleep 5; done
bash <(curl -sL https://raw.githubusercontent.com/syouit523/dotfiles-public/main/scripts/init.sh)
```

全ターゲットの一覧は `make help` で確認できます。

## 利用可能なコマンド

### 基本セットアップ
- `make bootstrap` または `make b`: 環境に応じた基本セットアップを実行
  - macOS: Xcode CLT、Homebrew、パッケージ、dotfiles、Zsh、tmux のセットアップ
  - Linux (Ubuntu): 日本語ロケール、Homebrew on Linux、パッケージ、フォント、dotfiles、Zsh、tmux のセットアップ（GUI アプリは `make linux_gui_setup` で別途）
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
  - プラグインは隔離された tmux サーバー上で自動インストールされます（稼働中のセッションには影響しません）
  - 自動インストールに失敗した場合は、`tmux` セッション内で `Ctrl+Space` + `I`（大文字のI）を押して手動インストールしてください
  - **利用可能な機能**:
    - `Ctrl+H/J/K/L`: tmuxペイン間の移動（vim/neovimとシームレスに連携）
    - セッションの自動保存・復元（tmux-resurrect/continuum）
    - CPU/メモリ使用率の表示（ステータスバー左側）

### テスト
- `make test` または `make t`: すべてのテストを実行
  - 初回実行時は自動的にBATSテストフレームワークをインストールします
  - 主要なシェルスクリプトの機能をテストします
  - テスト対象:
    - `deploy-configs.sh`: リンク/コピー/削除 + backup_file タイムスタンプ
    - `git-clone.sh`: リポジトリクローンとシンボリックリンク作成
    - `setup-gitconfig.sh`: 対話 + `DOTFILES_GIT_USER_NAME/EMAIL` + `NONINTERACTIVE`
    - `change-default-shell.sh`: brew パス優先選択 + `SHELLS_FILE` 注入
    - 各種 config ファイル / Brewfile の構文検証

### その他
- `make font` または `make f`: フォントのインストール
- `make ssh-key-gen`: SSHキーを生成
- `make linux_gui_setup`: Linux用GUIアプリケーション（Flatpak）のセットアップ
- `make clean` または `make c`: 環境をクリーンアップ（Homebrew、dotfiles、シェルの設定を削除）

## ディレクトリ構成

| パス | 内容 |
|------|------|
| `docs/` | 各ツールの操作方法・キーバインドのドキュメント |
| `Makefile` | すべてのセットアップの入口（`make help` で一覧表示） |
| `scripts/` | セットアップスクリプト本体（`scripts/linux/` は Linux 専用） |
| `mac/scripts/` | macOS 専用スクリプト（Xcode CLT インストールなど） |
| `configs/` | 各ツールの設定ファイル。`make link` で `$HOME` 配下へ symlink される |
| `Brewfiles/` | Homebrew パッケージ定義（minimum / extra / macApps） |
| `bin/` | `~/.local/bin` に配置されるユーティリティ（`clean-tmux` など） |
| `tests/` | BATS テストスイート（`make test`） |
| `iterm/` | iTerm2 カラーテーマ（手動インポート用、`iterm/README.md` 参照） |
| `deps/` | セットアップ時に外部リポジトリが clone される場所（git 管理外、`make clean-deps` で削除可） |

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

`.github/workflows/test.yml` に GitHub Actions ワークフローが設定済みです。

機能:
- ShellCheck による静的解析（pull request / 手動トリガーで実行）
- **Linux Bootstrap Test**（`.github/workflows/linux-bootstrap-test.yml`）: Ubuntu ランナー上で `NONINTERACTIVE=1 make bootstrap` を実際に実行し、ツールのバージョン要件（neovim 0.11+ / fzf 0.48+ / tmux 3.2+）と設定の配置を検証。セットアップ関連ファイルを変更した PR と手動トリガーで実行
- BATS テストの CI は個人用リポジトリのため無効化中（ワークフロー内のコメントを外せば再有効化できます）。ローカルでは `make test` で実行してください
