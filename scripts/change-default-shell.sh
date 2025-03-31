#!/bin/bash

# 一時ファイルを作成
tmpfile=$(mktemp /tmp/available_shells.XXXXXX)

# 利用可能なシェルのリストを取得して一時ファイルに保存
cat /etc/shells > "$tmpfile"

# 現在のシェルを表示
echo "現在のシェル: $SHELL"
echo -e "\n利用可能なシェル:"

# シェルのリストを番号付きで表示
counter=1
while IFS= read -r shell; do
    # コメント行をスキップ
    [ "$(echo "$shell" | grep -q '^#')" ] && continue
    # 空行をスキップ
    [ -z "$shell" ] && continue
    
    echo "$counter) $shell"
    eval "shell_$counter=\"$shell\""
    counter=$((counter + 1))
done < "$tmpfile"

# 一時ファイルを削除
rm -f "$tmpfile"

# ユーザーに選択させる
echo -e "\nデフォルトシェルとして設定するものを番号で選択してください："
read choice

# 選択が有効か確認
eval "selected_shell=\"\$shell_$choice\""
if [[ -n "$selected_shell" ]]; then
    
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
