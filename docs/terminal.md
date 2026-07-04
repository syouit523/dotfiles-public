# ターミナル(WezTerm / Ghostty / iTerm2)

3つのターミナルすべてに **coolnight カラーテーマ**(ダークブルー背景 `#011423` 系)を適用しています。Neovim の tokyonight カスタムも同系色で、ターミナルとエディタの見た目が揃います。

フォントはいずれも Nerd Font(starship / p10k のアイコン表示に必要)。`make bootstrap` の Brewfile で `font-hack-nerd-font` / `font-meslo-lg-nerd-font` がインストールされます。

## WezTerm

設定: `configs/wezterm/wezterm.lua`(→ `~/.config/wezterm/`)

- フォント: MesloLGS Nerd Font Mono 13pt
- coolnight カラー(ANSI 16色 + カーソル / 選択色)
- 背景の透過 75% + ブラー(macOS)
- ウィンドウ装飾は RESIZE のみ(タイトルバーなし)

## Ghostty

設定: `configs/ghostty/config`(→ `~/.config/ghostty/`)

- フォント: Hack Nerd Font Mono 13pt
- coolnight カラー(WezTerm から移植)
- 背景の透過 75% + ブラー
- `Shift+Enter` で改行を入力(`\x1b\r` を送信。Claude Code などの複数行入力用)
- `window-vsync = false`(スリープ復帰時の文字化け対策)

プロンプトのアイコンが `?` に化ける場合は Ghostty を完全再起動してください(フォントキャッシュの再読み込み)。

## iTerm2

- 設定 plist: `configs/iterm2/com.googlecode.iterm2.plist` — `make link` / `make copy` で `~/Library/Preferences/` に自動配置されます(iTerm2 の再起動後に反映)
- カラーテーマ: `iterm/theme/coolnight.itermcolors` — 手動インポートが必要です:
  1. iTerm2 の Settings > Profiles > Colors を開く
  2. 右下の Color Presets... > Import... で `iterm/theme/coolnight.itermcolors` を選択
  3. Color Presets... から coolnight を選択

詳細は [iterm/README.md](../iterm/README.md) を参照。

## テーマに関する補足

coolnight の元テーマは ANSI color 7(白)がシアン(`#24EAF7`)に設定されていましたが、白系文字が正しく明色で表示されるよう wezterm / ghostty では修正済みです(通常白: `#CBE0F0`、明るい白: `#FFFFFF`)。

True color は tmux 側でも全ターミナル向けに有効化しています(`docs/tmux.md` 参照)。
