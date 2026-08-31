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
| [tmux-agent-indicator](https://github.com/accessd/tmux-agent-indicator) | AI エージェント(Claude Code 等)の状態をペインボーダー・ウィンドウタイトル・ステータスバーに表示(後述) |

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

## AI エージェントの状態表示(tmux-agent-indicator)

tmux ペイン内で動く AI コーディングエージェント(Claude Code 等)の状態を、ペインボーダー色・ウィンドウタイトル・ステータスバーのアイコンで表示します。複数のプロジェクトでエージェントを並行して走らせたときに、どれが作業中でどれが応答待ちなのかをペインを切り替えずに把握するためのものです。

状態はプロセスの監視ではなく**エージェントのライフサイクルフックから供給**されるため、遷移が正確に反映されます。ペイン単位で `running` / `needs-input` / `done` の3状態を追跡します。

### 表示

| 状態 | 表示 |
|---|---|
| `running` | ステータスバーにエージェントのアイコン(既定 `🤖`)が表示される |
| `needs-input` | ペインボーダーとウィンドウタイトルが黄色になる |
| `done` | ペインボーダーが緑、ウィンドウタイトルが赤になる |

状態は対象ペインにフォーカスすると解除されます(`@agent-indicator-reset-on-focus 'on'`)。needs-input / done への遷移時には tmux の `display-message` 通知も表示されます(プラグイン既定で有効)。

依存: tmux 3.1+ / bash 4+ / Python 3。macOS 標準の bash は 3.2 なので Homebrew の bash が必要です。

### Claude Code 側の設定

状態の供給元として `~/.claude/settings.json` への hook 登録が必要です(このリポジトリの管理対象外)。プラグイン同梱のテンプレート `hooks/claude-hooks.json` と同じ内容を登録します。

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state off" }] },
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state running" }] }
    ],
    "PermissionRequest": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state needs-input" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-agent-indicator/scripts/agent-state.sh --agent claude --state done" }] }
    ]
  }
}
```

同じイベントに既に別の hook(デスクトップ通知など)を登録している場合は、その配列に追記すれば両方が発火します。上書きは不要です。hooks の変更は起動中の Claude Code セッションには自動反映されないため、`/hooks` で確認するか再起動してください。

Codex CLI / OpenCode にも対応しています。設定方法は[プラグインの README](https://github.com/accessd/tmux-agent-indicator#installation)を参照してください。それ以外のエージェントも `scripts/agent-state.sh --agent <name> --state <state>` を直接呼べば統合できます。

なお、プラグイン付属の `install.sh`(curl ワンライナー)は `~/.claude/settings.json` を自動書き換えするため使いません。このリポジトリでは上記の hook を手動管理します。

### 主な設定(tmux.conf)

```tmux
set -g @agent-indicator-border-enabled 'on'     # ペインボーダー色の変更
set -g @agent-indicator-indicator-enabled 'on'  # ステータスバーのアイコン表示
set -g @agent-indicator-reset-on-focus 'on'     # フォーカスするまで色を維持
```

ステータスバーへの表示は `status-right` 内の `#{agent_indicator}` プレースホルダで行います。このほか、状態別の色(`@agent-indicator-needs-input-border` 等)、エージェント別アイコン(`@agent-indicator-icons`)、トークン使用率表示(`#{agent_limits}`)、セッションドット(`#{agent_session_dots}`)などのオプションがあります。詳細は[プラグインの README](https://github.com/accessd/tmux-agent-indicator#configuration)を参照してください。

なお、新規セッション作成時の自動縦分割(`session-created` フック)とは競合しません。

## ユーティリティ: clean-tmux

`bin/clean-tmux`(`make link` で `~/.local/bin/clean-tmux` に配置)は、全セッションの kill と resurrect の保存データの削除を行います。

```bash
clean-tmux          # 確認プロンプトあり
clean-tmux --force  # 確認なしで実行
```

保存済みセッションが壊れて復元がおかしくなった場合のリセットに使います。**非可逆な操作**なので注意してください。

### resurrect の保存先

tmux-resurrect の保存先は次の順で決まります(tmux-resurrect の `scripts/helpers.sh`)。

1. `@resurrect-dir` が設定されていればそのパス(このリポジトリでは未設定)
2. `~/.tmux/resurrect/` が**既に存在すれば**そこ(古いレイアウトとの後方互換)
3. どちらでもなければ `${XDG_DATA_HOME:-~/.local/share}/tmux/resurrect/`

新規に構築した環境では 2 のディレクトリが作られないため、実際の保存先は通常 **`~/.local/share/tmux/resurrect/`** になります。`clean-tmux` は 2 と 3 の両方を削除対象にします(`@resurrect-dir` で別の場所を指定している場合は対象外)。
