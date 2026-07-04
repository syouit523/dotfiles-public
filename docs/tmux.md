# tmux

設定ファイル: `configs/tmux/tmux.conf`(`make link` で `~/.tmux.conf` に配置)

## 基本

- **プレフィックスキー: `Ctrl+Space`**(デフォルトの `Ctrl+b` から変更済み)
- マウス操作有効(ペイン選択、リサイズ、スクロール)
- True color / undercurl 対応(全ターミナル)
- 履歴バッファ 50,000 行

## キーバインド一覧

以下、`prefix` = `Ctrl+Space`。

### ペイン操作

| キー | 動作 |
|---|---|
| `prefix` `\|` | 縦分割(現在のディレクトリを引き継ぐ) |
| `prefix` `-` | 横分割(現在のディレクトリを引き継ぐ) |
| `Ctrl+h / j / k / l` | ペイン間移動(**prefix 不要**。vim-tmux-navigator により vim/nvim のウィンドウともシームレスに移動) |
| `prefix` `h / j / k / l` | ペインのリサイズ(5セルずつ。リピート可: prefix を押し直さず連打できる) |
| `prefix` `m` | ペインの最大化 / 元に戻す(トグル) |

### コピーモード(vi キーバインド)

| キー | 動作 |
|---|---|
| `prefix` `[` | コピーモード開始 |
| `v` | 選択開始 |
| `y` | 選択範囲をコピー |
| `q` | コピーモード終了 |

- マウスドラッグで選択してもコピーモードは終了しません(継続して操作可能)
- マウスホイールのスクロールは1行単位

### その他

| キー | 動作 |
|---|---|
| `prefix` `r` | `~/.tmux.conf` を再読み込み |

## セッション / ウィンドウの命名

セッション名・ウィンドウ名は **zsh の precmd フックが現在のディレクトリ名で自動リネーム**します(`configs/zsh/zshrc` 参照)。tmux 側の `automatic-rename` / `allow-rename` は無効化してあります。ディレクトリを移動したときだけリネームされます。

また、新規セッション作成時に自動で縦分割されます(`session-created` フック)。

## プラグイン

TPM(Tmux Plugin Manager)で管理。`make tmux` 実行時に隔離サーバー上で自動インストールされます(稼働中のセッションには影響しません)。

| プラグイン | 用途 |
|---|---|
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | `Ctrl+h/j/k/l` で tmux ペインと vim/nvim ウィンドウを区別なく移動 |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | セッション(ペイン構成・作業ディレクトリ・ペイン内容)の保存と復元 |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | resurrect の**15分ごとの自動保存**と、tmux 起動時の**自動復元**(`@continuum-restore 'on'`) |
| [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load) | ステータスバー左側に CPU / メモリ使用率を表示(2秒間隔) |

### TPM の操作

| キー | 動作 |
|---|---|
| `prefix` `I` | プラグインのインストール |
| `prefix` `U` | プラグインのアップデート |
| `prefix` `Alt+u` | 設定から削除したプラグインのアンインストール |

### resurrect の手動操作

| キー | 動作 |
|---|---|
| `prefix` `Ctrl+s` | セッションを保存 |
| `prefix` `Ctrl+r` | 保存したセッションを復元 |

通常は continuum が自動保存・自動復元するため手動操作は不要です。

## ユーティリティ: clean-tmux

`bin/clean-tmux`(`make link` で `~/.local/bin/clean-tmux` に配置)は、全セッションの kill と resurrect の保存データ(`~/.tmux/resurrect/`)の削除を行います。

```bash
clean-tmux          # 確認プロンプトあり
clean-tmux --force  # 確認なしで実行
```

保存済みセッションが壊れて復元がおかしくなった場合のリセットに使います。**非可逆な操作**なので注意してください。
