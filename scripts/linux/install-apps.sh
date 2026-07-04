#!/bin/bash

set -e

# Install wezterm(terminal)
## ref: https://wezfurlong.org/wezterm/index.html
# -y: 非対話実行でもブロックしない
# NOTE: `flatpak run` はセットアップ中にアプリを起動してしまい、
#       スクリプト内の alias は子シェル終了とともに消えるため削除した
#       （wezterm の alias が必要ならシェル設定側 configs/ に置く）
flatpak install -y flathub org.wezfurlong.wezterm
