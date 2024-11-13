#!/bin/bash

# Homebrewのサービスの停止
read -p "Homebrewのサービスを停止しますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Homebrewのサービスを停止中..."
    brew services stop --all
fi

# Mac App Storeアプリケーションのアンインストール
if command -v brew mas &> /dev/null; then
    read -p "Mac App Storeアプリケーションをアンインストールしますか？(y/N): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "Mac App Storeアプリケーションをアンインストール中..."
        brew mas list | cut -d' ' -f1 | xargs -I{} mas uninstall {}
    fi
fi

# Formulaのアンインストール
read -p "Homebrewのフォーミュラ（コマンドラインツール）をアンインストールしますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "フォーミュラをアンインストール中..."
    brew list --formula | xargs brew uninstall --force
fi

# Casksのアンインストール
read -p "Homebrewのcask（GUIアプリケーション）をアンインストールしますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Caskをアンインストール中..."
    brew list --cask | xargs brew uninstall --force
fi

# キャッシュの削除
brew cleanup -s

# Homebrewのアンインストール
read -p "Homebrew自体をアンインストールしますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Homebrewをアンインストール中..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
fi

echo "アンインストール処理が完了しました。"
