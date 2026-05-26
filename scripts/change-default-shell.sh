#!/bin/bash

select_shell_noninteractive() {
  local target="$1"
  # フルパス指定にも対応（/bin/zsh → zsh に正規化してから検索）
  local basename_target
  basename_target=$(basename "$target")

  # /etc/shells から候補を全て列挙し、Homebrew パスを優先する。
  # システムの /bin/zsh が古いケースがあるため、brew zsh を見つけたらそちらを使う。
  local matches
  matches=$(grep -E "^[^#]" /etc/shells | grep -E "/${basename_target}$" || true)

  local found=""
  # 優先順位: /opt/homebrew → /usr/local → /home/linuxbrew → その他
  for prefix in /opt/homebrew/bin /usr/local/bin /home/linuxbrew/.linuxbrew/bin; do
    found=$(echo "$matches" | grep -E "^${prefix}/${basename_target}$" | head -n1 || true)
    [ -n "$found" ] && { echo "$found"; return 0; }
  done

  # 上記で見つからなければ /etc/shells の最初のエントリ
  found=$(echo "$matches" | head -n1)
  if [ -z "$found" ]; then
    found=$(command -v "$basename_target" 2>/dev/null)
  fi
  echo "$found"
}

if [ -n "$DOTFILES_DEFAULT_SHELL" ]; then
  selected_shell=$(select_shell_noninteractive "$DOTFILES_DEFAULT_SHELL")
  if [ -z "$selected_shell" ]; then
    echo "DOTFILES_DEFAULT_SHELL=$DOTFILES_DEFAULT_SHELL not found in /etc/shells. Skipping."
    exit 0
  fi
  echo "Using DOTFILES_DEFAULT_SHELL: $selected_shell"
elif [ "$NONINTERACTIVE" = "1" ]; then
  echo "NONINTERACTIVE: DOTFILES_DEFAULT_SHELL not set, skipping shell change."
  exit 0
else
  tmpfile=$(mktemp /tmp/available_shells.XXXXXX)
  cat /etc/shells > "$tmpfile"

  echo "Current shell: $SHELL"
  echo -e "\nAvailable shells:"

  counter=1
  while IFS= read -r shell; do
    echo "$shell" | grep -q '^#' && continue
    [ -z "$shell" ] && continue
    echo "$counter) $shell"
    eval "shell_$counter=\"$shell\""
    counter=$((counter + 1))
  done < "$tmpfile"
  rm -f "$tmpfile"

  echo -e "\nEnter the number of the shell you want to set as default:"
  read -r choice
  eval "selected_shell=\"\$shell_$choice\""
fi

if [ -n "$selected_shell" ]; then
  if sudo -n chsh -s "$selected_shell" "$USER"; then
    echo "Default shell changed to $selected_shell"
    echo "You need to log out and log back in for changes to take effect"
  else
    echo "Failed to change shell"
  fi
else
  echo "Invalid selection"
fi
