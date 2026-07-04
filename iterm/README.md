# iTerm2 settings

## 設定の反映方法

### 1. 設定 plist(自動)

`configs/iterm2/com.googlecode.iterm2.plist` が `make link` / `make copy` で
`~/Library/Preferences/com.googlecode.iterm2.plist` に配置されます。
iTerm2 を再起動すると反映されます。

### 2. カラーテーマ(手動インポート)

`theme/coolnight.itermcolors` は手動でインポートします:

1. iTerm2 の Settings > Profiles > Colors を開く
2. 右下の Color Presets... > Import... で `theme/coolnight.itermcolors` を選択
3. Color Presets... のリストから coolnight を選択
