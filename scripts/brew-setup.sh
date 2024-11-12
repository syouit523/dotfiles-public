#!/bin/bash

# $1: Brewfile path

# sudoのパスワード認証をキャッシュ
sudo -v

# sudo認証のタイムアウトを更新し続けるバックグラウンドプロセスを開始
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Brewfileからパッケージをインストール
brew bundle --file="${1}"
