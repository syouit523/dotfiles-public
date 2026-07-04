# fish

設定ファイル: `configs/fish/config/fish/`(→ `~/.config/fish/`)、プラグイン定義: `configs/fish/fish_plugins`

セットアップ: `make fish`(fish 本体 + fisher + プラグインをインストール)

## 構成

`config.fish` の読み込み順:

1. 基本設定(greeting 無効化、`EDITOR=nvim`)
2. `shoichi/alias.fish` — エイリアス
3. `shoichi/path.fish` — PATH と fzf 設定
4. OS 別設定(`config-osx.fish` / `config-linux.fish` / `config-windows.fish`)
5. `config-local.fish` — **git 管理外のローカル設定**(存在すれば読み込み。マシン固有の設定はここに置く)

## プラグイン(fisher 管理)

`fish_plugins` に定義。`fisher update` で同期されます。

### tide(プロンプト)

[ilancosman/tide](https://github.com/IlanCosman/tide) v6。初回またはメジャーアップデート後は対話ウィザードで見た目を設定します:

```fish
tide configure
```

### fzf.fish(あいまい検索)

[PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish)。主なキーバインド:

| キー | 動作 |
|---|---|
| `Ctrl+Alt+F` | ファイル検索(プレビュー付き) |
| `Ctrl+R` | コマンド履歴検索 |
| `Ctrl+Alt+L` | git log 検索 |
| `Ctrl+Alt+S` | git status のファイル検索 |
| `Ctrl+Alt+P` | プロセス検索(kill に便利) |
| `Ctrl+V` | シェル変数検索 |

> 旧プラグイン(jethrokuan/fzf)とはキーバインドが異なります。`fzf_configure_bindings` で変更可能です。

## エイリアス

| エイリアス | 実体 |
|---|---|
| `ls` | `ls -p -G` |
| `la` / `ll` / `lla` | `ls -A` / `ls -l` / `ll -A` |
| `ll`(macOS で exa がある場合) | `exa -l -g --icons` |
| `g` | `git` |

## PATH / ツール連携(`path.fish`)

- `~/bin`、`~/.local/bin`、Go(`$GOPATH/bin`)を PATH に追加
- fzf のファイル列挙は zsh と同じく `fd` ベース(隠しファイル込み、`.git` 除外)
- macOS では rbenv 初期化、Homebrew shellenv、diff-highlight の PATH 追加(Apple Silicon / Intel 両対応)
