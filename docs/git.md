# git

設定ファイル: `configs/git/gitconfig`(→ `~/.gitconfig`)、`configs/git/gitignore_global`(→ `~/.gitignore_global`)

- エディタ: nvim
- pager / diff: **delta**(構文ハイライト付き side-by-side 表示。`n` / `N` でファイル間を移動)
- `pull.rebase = true`(pull は常に rebase)
- `push.autoSetupRemote = true`(初回 push で upstream を自動設定)
- `init.defaultBranch = main`

## エイリアス一覧

`g` が `git` のエイリアスなので `g st` のように使えます(zsh / fish 共通)。

### 日常操作

| エイリアス | 実体 | 説明 |
|---|---|---|
| `st` | `status` | |
| `d` | `diff` | delta で表示 |
| `b` | `branch` | |
| `ch` | `checkout` | |
| `cm` | `commit` | |
| `ca` | `!git add -A && git commit` | 全変更をステージしてコミット |
| `amend` | `commit --amend` | 直前のコミットを修正 |
| `unstage` | `reset HEAD --` | ステージ取り消し |
| `pl` | `pull` | |
| `ph` | `!git push -u origin HEAD` | 現在のブランチを upstream 設定付きで push |
| `lg` | `log --oneline --graph --decorate --all` | 全ブランチのグラフ表示 |

### GitHub 連携(gh CLI)

| エイリアス | 説明 |
|---|---|
| `open` / `o` | 現在のリポジトリをブラウザで開く |
| `pr` | プルリクエストを作成(ブラウザで開く) |
| `pp` | プルリクエストを編集 |
| `showpr <branch>` | 指定ブランチが最初にマージされた PR を表示 |
| `openpr <branch>` | 指定ブランチが最初にマージされた PR をブラウザで開く |

### ブランチ / スタッシュ / その他

| エイリアス | 説明 |
|---|---|
| `track` | 現在のブランチをリモートの同名ブランチに追跡設定 |
| `delete-branch <name>` | ブランチ削除(`-d`) |
| `fetch-all` / `pull-all` | 全リモートの fetch / pull |
| `stash-all` | 未追跡ファイル込みでスタッシュ |
| `stash-pop` / `stash-list` | スタッシュの取り出し / 一覧 |
| `resolve` | mergetool(vimdiff)でコンフリクト解決してコミット |
| `rebase-continue` | rebase を続行 |

## user.name / user.email の設定

`~/.gitconfig` に user 情報はコミットされていません。`make link` / `make copy` 時に `setup-gitconfig.sh` が対話で設定します:

- 対話モード: 直近コミットの著者をデフォルト値として確認プロンプト
- `DOTFILES_GIT_USER_NAME` / `DOTFILES_GIT_USER_EMAIL` 指定時: その値を使用
- `NONINTERACTIVE=1`: 既存の global 設定を維持(なければスキップ)

## 会社用 gitconfig の分離

`make link` 実行時に「COMPANY USER INFO を設定するか」を聞かれます。`y` にすると:

1. `~/workspace/<会社名>/.<会社名>.gitconfig` に会社用の user.name / user.email を書き込み
2. `~/.gitconfig` に `includeIf "gitdir:~/workspace/<会社名>/"` を追加

これにより **`~/workspace/<会社名>/` 配下のリポジトリだけ会社のメールアドレスでコミット**されます。個人リポジトリは global 設定のまま。

## gitignore_global

全リポジトリ共通で無視されるパターン(`core.excludesFile`):

- `*~`、`.DS_Store`
- `**/.claude/*`(ただし `**/.claude/commands/` は除外しない)
- Firebase CLI のログ / キャッシュ(`*-debug.log`、`.firebase/`)
