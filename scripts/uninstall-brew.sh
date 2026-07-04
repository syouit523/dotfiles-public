#!/bin/bash

# brew が無ければ何もすることがない
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrewはインストールされていません。スキップします。"
    exit 0
fi

# Homebrewのサービスの停止
read -r -p "Homebrewのサービスを停止しますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Homebrewのサービスを停止中..."
    brew services stop --all
fi

# Mac App Storeアプリケーションのアンインストール
if command -v brew &> /dev/null && command -v mas &> /dev/null; then
    read -r -p "Mac App Storeアプリケーションをアンインストールしますか？(y/N): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "Mac App Storeアプリケーションをアンインストール中..."
        mas list | awk '{print $1}' | xargs -I{} mas uninstall {}
    fi
fi

# Formulaのアンインストール
read -r -p "Homebrewのフォーミュラ（コマンドラインツール）をアンインストールしますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "フォーミュラをアンインストール中..."
    # 空リストのとき xargs が引数なしで brew uninstall を実行しないようガード
    formulas=$(brew list --formula)
    if [ -n "$formulas" ]; then
        echo "$formulas" | xargs brew uninstall --force
    else
        echo "アンインストール対象のフォーミュラはありません。"
    fi
fi

# Casksのアンインストール
read -r -p "Homebrewのcask（GUIアプリケーション）をアンインストールしますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Caskをアンインストール中..."
    casks=$(brew list --cask)
    if [ -n "$casks" ]; then
        echo "$casks" | xargs brew uninstall --force
    else
        echo "アンインストール対象のcaskはありません。"
    fi
fi

# キャッシュの削除
brew cleanup -s

# Homebrewのアンインストール
read -r -p "Homebrew自体をアンインストールしますか？(y/N): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Homebrewをアンインストール中..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
fi

echo "アンインストール処理が完了しました。"
