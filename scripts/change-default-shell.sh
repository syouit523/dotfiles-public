#!/bin/bash

# テストから /etc/shells を差し替えるための環境変数。
# 通常実行時は /etc/shells を見る。
SHELLS_FILE="${SHELLS_FILE:-/etc/shells}"

# ostree ベース (Fedora Atomic / Bazzite 等) の判定マーカー。
# テストから差し替えられるよう環境変数化している。
OSTREE_BOOTED_FILE="${OSTREE_BOOTED_FILE:-/run/ostree-booted}"

select_shell_noninteractive() {
  local target="$1"
  # フルパス指定にも対応（/bin/zsh → zsh に正規化してから検索）
  local basename_target
  basename_target=$(basename "$target")

  # SHELLS_FILE から候補を全て列挙し、Homebrew パスを優先する。
  # システムの /bin/zsh が古いケースがあるため、brew zsh を見つけたらそちらを使う。
  local matches
  matches=$(grep -E "^[^#]" "$SHELLS_FILE" 2>/dev/null | grep -E "/${basename_target}$" || true)

  local found=""
  # 優先順位: /opt/homebrew → /usr/local → /home/linuxbrew → その他
  for prefix in /opt/homebrew/bin /usr/local/bin /home/linuxbrew/.linuxbrew/bin; do
    found=$(echo "$matches" | grep -E "^${prefix}/${basename_target}$" | head -n1 || true)
    [ -n "$found" ] && { echo "$found"; return 0; }
  done

  # 上記で見つからなければ SHELLS_FILE の最初のエントリ
  found=$(echo "$matches" | head -n1)
  if [ -z "$found" ]; then
    found=$(command -v "$basename_target" 2>/dev/null)
  fi
  echo "$found"
}

# bats から関数を直接 source して呼べるよう、エントリポイントをガード
# (CHANGE_SHELL_LIB_ONLY=1 を渡せば下のメイン処理はスキップ)
if [ "${CHANGE_SHELL_LIB_ONLY:-0}" = "1" ]; then
  return 0 2>/dev/null || exit 0
fi

if [ -n "$DOTFILES_DEFAULT_SHELL" ]; then
  selected_shell=$(select_shell_noninteractive "$DOTFILES_DEFAULT_SHELL")
  if [ -z "$selected_shell" ]; then
    echo "DOTFILES_DEFAULT_SHELL=$DOTFILES_DEFAULT_SHELL not found in $SHELLS_FILE. Skipping."
    exit 0
  fi
  echo "Using DOTFILES_DEFAULT_SHELL: $selected_shell"
elif [ "$NONINTERACTIVE" = "1" ]; then
  echo "NONINTERACTIVE: DOTFILES_DEFAULT_SHELL not set, skipping shell change."
  exit 0
else
  echo "Current shell: $SHELL"
  echo -e "\nAvailable shells:"

  # eval は使わない: ユーザー入力や SHELLS_FILE の内容が
  # シェルコードとして実行される危険があるため、配列 + 数値検証にする
  shells=()
  counter=1
  while IFS= read -r shell; do
    echo "$shell" | grep -q '^#' && continue
    [ -z "$shell" ] && continue
    echo "$counter) $shell"
    shells+=("$shell")
    counter=$((counter + 1))
  done < "$SHELLS_FILE"

  echo -e "\nEnter the number of the shell you want to set as default:"
  read -r choice
  case "$choice" in
    ''|*[!0-9]*)
      echo "Invalid selection: not a number" >&2
      exit 1
      ;;
  esac
  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#shells[@]}" ]; then
    echo "Invalid selection: out of range" >&2
    exit 1
  fi
  selected_shell="${shells[$((choice - 1))]}"
fi

if [ -z "$selected_shell" ]; then
  echo "Invalid selection" >&2
  exit 1
fi

# Fedora Atomic (Bazzite 等、ostree ベース) では brew 導入シェルを
# login shell にすることが公式に非推奨とされている
# (システムが起動不能になる報告あり: ublue-os/bazzite#4159)。
# 自動変更はせず、ターミナルエミュレータ側での設定を案内する。
if [ -f "$OSTREE_BOOTED_FILE" ]; then
  case "$selected_shell" in
    /home/linuxbrew/*|/var/home/linuxbrew/*)
      echo "Detected ostree-based OS (Fedora Atomic / Bazzite)."
      echo "Changing the login shell to a Homebrew shell is not recommended here."
      echo "Instead, configure your terminal emulator to launch it, e.g. Ptyxis:"
      echo "  Settings > Profiles > Custom Command: $selected_shell"
      echo "Skipping login shell change."
      exit 0
      ;;
  esac
fi

# chsh は Fedora 系に同梱されないため usermod にフォールバックする
if command -v chsh >/dev/null 2>&1; then
  change_cmd=(sudo -n chsh -s "$selected_shell" "$USER")
else
  change_cmd=(sudo -n usermod --shell "$selected_shell" "$USER")
fi

if "${change_cmd[@]}"; then
  echo "Default shell changed to $selected_shell"
  echo "You need to log out and log back in for changes to take effect"
else
  echo "Failed to change shell to $selected_shell" >&2
  echo "Hint: ensure sudo cache is active (run 'make check-sudo' first)" >&2
  exit 1
fi
