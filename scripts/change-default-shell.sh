#!/bin/bash

# 利用可能なシェルのリストを取得
available_shells=$(cat /etc/shells)

# 現在のシェルを表示
echo "現在のシェル: $SHELL"
echo -e "\n利用可能なシェル:"

# シェルのリストを番号付きで表示
counter=1
declare -A shell_map
while IFS= read -r shell; do
    # コメント行をスキップ
    [[ $shell =~ ^#.*$ ]] && continue
    # 空行をスキップ
    [[ -z $shell ]] && continue
    
    echo "$counter) $shell"
    shell_map[$counter]=$shell
    ((counter++))
done <<< "$available_shells"

# ユーザーに選択させる
echo -e "\nデフォルトシェルとして設定するものを番号で選択してください："
read choice

# 選択が有効か確認
if [[ -n "${shell_map[$choice]}" ]]; then
    selected_shell="${shell_map[$choice]}"
    
    # シェルの変更を実行
    sudo -n chsh -s "$selected_shell"
    
    if [ $? -eq 0 ]; then
        echo "デフォルトシェルを $selected_shell に変更しました"
        echo "変更を適用するには再ログインが必要です"
    else
        echo "シェルの変更に失敗しました"
    fi
else
    echo "無効な選択です"
fi
