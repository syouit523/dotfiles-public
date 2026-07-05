#!/bin/bash

# タイトル表示
echo "====================================================="
echo "  Ubuntu コマンドライン日本語表示設定スクリプト"
echo "====================================================="
echo

# rootチェック
if [ "$(id -u)" -ne 0 ]; then
  echo "このスクリプトはroot権限が必要です。"
  echo "sudo ./setup-japanese.sh として実行してください。"
  exit 1
fi

echo "日本語環境のセットアップを開始します..."

# 非対話実行時は dpkg の conffile プロンプト等も抑止する
if [ "$NONINTERACTIVE" = "1" ]; then
  export DEBIAN_FRONTEND=noninteractive
fi

# 1. 必要なパッケージのインストール
echo "日本語言語パックをインストールしています..."
apt-get update
apt-get install -y language-pack-ja

# 2. 日本語ロケールの生成
echo "日本語ロケールを生成しています..."
locale-gen ja_JP.UTF-8

# 3. システムデフォルトロケールの設定
echo "システムデフォルトロケールを設定しています..."
update-locale LANG=ja_JP.UTF-8

# 4. ユーザー設定ファイルに環境変数を追加 (bash, fish, zsh)
echo "ユーザー設定ファイルを更新しています..."

# bash用設定
# sudo 経由なら実行ユーザーのホームを getent で解決する
# （/home/$SUDO_USER 決め打ちだと root 直接実行時に /home//.bashrc になる）
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi
BASHRC="$USER_HOME/.bashrc"

# 冪等性ガード: 実際に書き込む行 (LC_CTYPE) と同じパターンで判定する
if [ -f "$BASHRC" ] && grep -q "export LC_CTYPE=ja_JP.UTF-8" "$BASHRC"; then
  echo "環境変数の設定はすでに $BASHRC に存在します。"
else
  {
    echo ""
    echo "# 日本語表示設定"
    echo "export LANG=en_US.UTF-8"
    echo "export LC_CTYPE=ja_JP.UTF-8"
  } >> "$BASHRC"
  echo "環境変数の設定を $BASHRC に追加しました。"
fi

# フォントのインストール（オプション）
# NONINTERACTIVE 時は read で入力待ちにならないようスキップする
# (Makefile から sudo 経由で呼ばれるため、NONINTERACTIVE は
#  呼び出し側で明示的に env 渡しされる)
if [ "$NONINTERACTIVE" = "1" ]; then
  INSTALL_FONTS="n"
  echo "NONINTERACTIVE: skipping Japanese font installation prompt."
else
  echo "Do you want to install fonts of japanese？ [y/n]"
  read -n 1 -r INSTALL_FONTS
  echo
fi

if [[ $INSTALL_FONTS =~ ^[Yy]$ ]]; then
  echo "日本語フォントをインストールしています..."
  apt-get install -y fonts-noto-cjk fonts-ipafont fonts-vlgothic
  echo "日本語フォントのインストールが完了しました。"
fi

echo
echo "セットアップが完了しました。"
echo "変更を適用するには、ターミナルを再起動するか、以下のコマンドを実行してください："
echo "bashユーザー: source ~/.bashrc"
echo "fishユーザー: source ~/.config/fish/config.fish"
echo "zshユーザー: source ~/.zshrc"
echo
echo "注意: ターミナルエミュレータの設定で「文字エンコーディング」がUTF-8に設定されていることを確認してください。"
