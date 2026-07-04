# ドキュメント

各ツールの操作方法・プラグインの使い方をまとめています。セットアップ手順(ワンライナーインストール、`make` ターゲット一覧)はリポジトリルートの [README.md](../README.md) を参照してください。

| ドキュメント | 内容 |
|---|---|
| [tmux.md](tmux.md) | tmux のキーバインド、プラグイン(resurrect / continuum / vim-tmux-navigator 等)の使い方 |
| [zsh.md](zsh.md) | zsh の構成、エイリアス、fzf / zoxide / fzf-git などのコマンド拡張 |
| [fish.md](fish.md) | fish の構成、tide / fzf.fish プラグインの使い方 |
| [nvim.md](nvim.md) | Neovim のキーマップ一覧、プラグインの使い方、LSP の構成 |
| [git.md](git.md) | git エイリアス一覧、delta、会社用 gitconfig の分離設定 |
| [terminal.md](terminal.md) | WezTerm / Ghostty / iTerm2 の設定とテーマ |

## 設定ファイルとドキュメントの対応

| ドキュメント | 設定ファイル |
|---|---|
| tmux.md | `configs/tmux/tmux.conf` |
| zsh.md | `configs/zsh/zshrc`, `configs/zsh/shoichi/*.zsh`, `configs/starship/starship.toml` |
| fish.md | `configs/fish/config/fish/`, `configs/fish/fish_plugins` |
| nvim.md | `configs/nvim/` |
| git.md | `configs/git/gitconfig`, `configs/git/gitignore_global` |
| terminal.md | `configs/wezterm/`, `configs/ghostty/`, `configs/iterm2/`, `iterm/` |

設定を変更する場合はこのリポジトリの `configs/` 配下を編集してください(`make link` でデプロイした環境では symlink 経由で即反映されます)。ドキュメントと設定が乖離しないよう、設定変更時は対応するドキュメントも更新してください。
