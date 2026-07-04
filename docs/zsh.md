# zsh

設定ファイル: `configs/zsh/zshrc`(→ `~/.zshrc`)と `configs/zsh/shoichi/*.zsh`(→ `~/.config/zsh/shoichi/`)

## 構成

読み込み順(`zshrc`):

1. 基本設定(`EDITOR=nvim`、emacs キーバインド、`LANG=ja_JP.UTF-8`)
2. プロンプト初期化(デフォルト: **starship**)
3. OS 別設定(`config-osx.zsh` / `config-linux.zsh`)
4. 補完初期化(`compinit`)
5. `command-extensions.zsh`(fzf / bat / thefuck など)
6. `alias.zsh`
7. tmux 自動リネーム、direnv、PATH
8. **zoxide 初期化(必ず末尾)**

### プロンプトの切り替え

`zshrc` の `prompt_type` を変更します:

- `starship`(デフォルト): 設定は `configs/starship/starship.toml`。OS アイコン、git ブランチ/ステータス/差分行数、言語バージョン(swift / terraform / lua / python / node)、AWS プロファイル、docker context、コマンド実行時間、現在時刻を表示
- `oh-my-zsh`: `shoichi/oh-my-zsh.zsh` 経由で oh-my-zsh + powerlevel10k を使用(`make zsh` でインストールされる)

## エイリアス(`alias.zsh`)

| エイリアス | 実体 | 説明 |
|---|---|---|
| `ls` / `l` | `eza --color=always --long --git --icons=always --no-user` | git ステータス・アイコン付きの一覧 |
| `lt` | `ls --tree` | ツリー表示 |
| `la` | `ls --all` | 隠しファイル込み |
| `lat` | `ls --all --tree` | 隠しファイル込みツリー |
| `g` | `git` | |

## コマンド拡張(`command-extensions.zsh`)

### fzf(ファジーファインダー)

ファイル列挙は `fd` ベース(隠しファイル込み、`.git` 除外)。

| キー | 動作 |
|---|---|
| `Ctrl+T` | ファイルをあいまい検索して挿入(**bat によるプレビュー付き**) |
| `Ctrl+R` | コマンド履歴をあいまい検索 |
| `Alt+C` | ディレクトリをあいまい検索して cd(**eza ツリープレビュー付き**) |
| `**` + `Tab` | パス補完をあいまい検索(例: `vim **<Tab>`、`cd **<Tab>`、`ssh **<Tab>`) |

### fzf-git(git オブジェクトのあいまい検索)

シェル上で `Ctrl+G` に続けて以下を押すと、対応する git オブジェクトを fzf で検索して挿入できます:

| キー | 対象 |
|---|---|
| `Ctrl+G` `Ctrl+F` | 変更ファイル(git status) |
| `Ctrl+G` `Ctrl+B` | ブランチ |
| `Ctrl+G` `Ctrl+T` | タグ |
| `Ctrl+G` `Ctrl+H` | コミットハッシュ(log) |
| `Ctrl+G` `Ctrl+R` | リモート |
| `Ctrl+G` `Ctrl+S` | スタッシュ |
| `Ctrl+G` `Ctrl+L` | reflog |
| `Ctrl+G` `Ctrl+W` | worktree |

例: `git rebase -i ` まで打って `Ctrl+G` `Ctrl+H` でコミットを選択。

### zoxide(スマートな cd)

`zoxide init zsh --cmd cd` により **`cd` コマンド自体が置き換わっています**:

```bash
cd foo        # 過去に訪れたディレクトリを頻度順にあいまいマッチしてジャンプ
cd foo bar    # 複数キーワードで絞り込み
cdi           # fzf で対話的に選択
cd -          # 直前のディレクトリへ
```

通常のパス指定(`cd ./dir`、`cd /absolute/path`)もそのまま動きます。

### その他

- **bat**: `BAT_THEME=tokyonight_night`(テーマは `make zsh_extensions` でインストール。未インストール環境では自動的にデフォルトテーマになる)
- **thefuck**(macOS のみ): 直前のコマンドの typo を `fuck` または `fk` で修正
- **direnv**: ディレクトリ移動時に `.envrc` を自動読み込み
- **zsh-autosuggestions**: 履歴ベースの薄色サジェストを `→`(または `End`)で確定
- **zsh-syntax-highlighting**: コマンドラインのリアルタイム構文ハイライト

## tmux セッションの自動リネーム

tmux 内でディレクトリを移動すると、セッション名・ウィンドウ名が**ディレクトリ名に自動で変わります**(precmd フック。同じディレクトリにいる間は再実行されないため、手動リネームは次の移動まで維持されます)。

## インストール関連

- `make zsh`: zsh 本体 + oh-my-zsh + powerlevel10k / omz 用プラグイン
- `make zsh_extensions`: fzf-git、bat テーマ、zsh-autosuggestions / zsh-syntax-highlighting(starship 経路用、`~/.zsh/` 配下)
