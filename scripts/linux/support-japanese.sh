#!/bin/bash

# タイトル表示
echo "====================================================="
echo "  Ubuntu コマンドライン日本語表示設定スクリプト"
echo "====================================================="
echo

# rootチェック
if [ $(id -u) -ne 0 ]; then
  echo "このスクリプトはroot権限が必要です。"
  echo "sudo ./setup-japanese.sh として実行してください。"
  exit 1
fi

echo "日本語環境のセットアップを開始します..."

# 1. 必要なパッケージのインストール
echo "日本語言語パックをインストールしています..."
apt update
apt install -y language-pack-ja

# 2. 日本語ロケールの生成
echo "日本語ロケールを生成しています..."
locale-gen ja_JP.UTF-8

# 3. システムデフォルトロケールの設定
echo "システムデフォルトロケールを設定しています..."
update-locale LANG=ja_JP.UTF-8

# 4. ユーザー設定ファイルに環境変数を追加 (bash, fish, zsh)
echo "ユーザー設定ファイルを更新しています..."

# bash用設定
BASHRC="/home/$SUDO_USER/.bashrc"
if ! grep -q "export LANG=ja_JP.UTF-8" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# 日本語表示設定" >> "$BASHRC"
  echo "export LANG=ja_JP.UTF-8" >> "$BASHRC"
  echo "export LC_ALL=ja_JP.UTF-8" >> "$BASHRC"
  echo "環境変数の設定を .bashrc に追加しました。"
else
  echo "環境変数の設定はすでに .bashrc に存在します。"
fi

# フォントのインストール（オプション）
echo "Do you want to install fonts of japanese？ [y/n]"
read -n 1 -r INSTALL_FONTS
echo

if [[ $INSTALL_FONTS =~ ^[Yy]$ ]]; then
  echo "日本語フォントをインストールしています..."
  apt install -y fonts-noto-cjk fonts-ipafont fonts-vlgothic
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
