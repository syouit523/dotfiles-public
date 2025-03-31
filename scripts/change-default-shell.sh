#!/bin/bash

# 一時ファイルを作成
tmpfile=$(mktemp /tmp/available_shells.XXXXXX)

# 利用可能なシェルのリストを取得して一時ファイルに保存
cat /etc/shells > "$tmpfile"

# 現在のシェルを表示
echo "Current shell: $SHELL"
echo -e "\nAvailable shells:"

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
echo -e "\nEnter the number of the shell you want to set as default:"
read choice

# 選択が有効か確認
eval "selected_shell=\"\$shell_$choice\""
if [ -n "$selected_shell" ]; then
    
    # シェルの変更を実行
    sudo -n chsh -s "$selected_shell"
    
    if [ $? -eq 0 ]; then
        echo "Default shell changed to $selected_shell"
        echo "You need to log out and log back in for changes to take effect"
    else
        echo "Failed to change shell"
    fi
else
    echo "Invalid selection"
fi
