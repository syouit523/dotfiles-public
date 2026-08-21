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
| [tmux-agent-status](https://github.com/samleeney/tmux-agent-status) | AI エージェント(Claude Code 等)の状態をサイドバーとステータスバーに表示(後述) |

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

## AI エージェントの状態表示(tmux-agent-status)

tmux ペイン内で動く AI コーディングエージェント(Claude Code 等)の状態を、各セッションの常設サイドバーとステータスバーに表示します。複数のプロジェクトでエージェントを並行して走らせたときに、どれが作業中でどれが応答待ちなのかを一目で把握するためのものです。

状態はプロセスの監視ではなく**エージェントのライフサイクルフックから供給**されるため、`working` / `done` の遷移が正確に反映されます。

### キーバインド

| キー | 動作 |
|---|---|
| `prefix` `S` | fzf の階層スイッチャーをポップアップ表示(`Ctrl+f` で tree ↔ agents 表示切替) |
| `prefix` `o` | サイドバーにフォーカス / 現在のウィンドウに作成 |
| `prefix` `N` | 次の INBOX 項目(完了 / 要応答)へジャンプ |
| `prefix` `W` | 現在のセッション / ペインを時限 wait モードにする |
| `prefix` `P` | 現在のセッション / ペインを park(後回し)する |

`prefix` `P` はプラグイン既定の `prefix` `p` から変更しています(`@agent-park-key`)。既定のままでは tmux 標準の `previous-window` を潰すためです。

サイドバーのペイン内では `x` = 閉じる、`p` = park、`w` = wait、`m` = 表示モード切替。スイッチャーのポップアップ内では `Enter` = 移動、`Tab` = 展開 / 折りたたみ、`Ctrl+x` = 閉じる、`Ctrl+p` = park、`Ctrl+w` = wait、`Ctrl+r` = 状態リセット。

### ステータスバーの表示

エージェント1つにつきグリフ1つが表示されます。グリフが種類、色が状態を表します。

| グリフ | エージェント |
|---|---|
| `✳` | Claude Code |
| `⬢` | Codex CLI |
| `◆` | Devin CLI |
| `●` | その他 |

| 色 | 状態 |
|---|---|
| 黄(点滅) | working(作業中) |
| シアン | waiting(wait モード) |
| マゼンタ | ask(応答待ち) |
| 緑 | done(完了) |

park したセッションはサイドバーとスイッチャーには残りますが、ステータスバーの集計からは除外されます。

### Claude Code 側の設定

状態の供給元として `~/.claude/settings.json` への hook 登録が必要です(このリポジトリの管理対象外)。

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-status/hooks/better-hook.sh UserPromptSubmit" }] }
    ],
    "PreToolUse": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-status/hooks/better-hook.sh PreToolUse" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-status/hooks/better-hook.sh Stop" }] }
    ],
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-status/hooks/better-hook.sh Notification" }] }
    ]
  }
}
```

同じイベントに既に別の hook(デスクトップ通知など)を登録している場合は、その配列に追記すれば両方が発火します。上書きは不要です。

Codex CLI / Devin CLI にも対応しています。設定方法は[プラグインの README](https://github.com/samleeney/tmux-agent-status#codex-cli-setup)を参照してください。

### 既知の制約

- tmux 3.7 では `after-kill-window` と `after-switch-client` が無効なオプションのため、tmux 起動時に `invalid option` の警告が2行出ます。サイドバーの再描画は他のフック(`window-layout-changed`、`pane-exited`、`client-attached` 等)でカバーされるので、動作への影響はありません。
- detach 状態のセッションではサイドバーの自動作成が走りません(対象ウィンドウが確定できないため)。attach 後に `prefix` `o` で作成できます。
- サイドバーは bash 4 以降を必要とします。macOS 標準の bash 3.2 では動かないため、Homebrew の bash(`/opt/homebrew/bin/bash`)が自動検出されます。別の場所に入れている場合は環境変数 `TMUX_AGENT_STATUS_BASH` でパスを指定してください。

なお、新規セッション作成時の自動縦分割(`session-created` フック)とは競合しません。プラグイン側が `set-hook -ga` で追記する実装のため、両方のフックが動作します。

## ユーティリティ: clean-tmux

`bin/clean-tmux`(`make link` で `~/.local/bin/clean-tmux` に配置)は、全セッションの kill と resurrect の保存データ(`~/.tmux/resurrect/`)の削除を行います。

```bash
clean-tmux          # 確認プロンプトあり
clean-tmux --force  # 確認なしで実行
```

保存済みセッションが壊れて復元がおかしくなった場合のリセットに使います。**非可逆な操作**なので注意してください。
