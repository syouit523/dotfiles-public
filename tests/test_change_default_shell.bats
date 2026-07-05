#!/usr/bin/env bats

# Tests for change-default-shell.sh
# 実スクリプトを CHANGE_SHELL_LIB_ONLY=1 で source して
# select_shell_noninteractive を直接テストする。

load test_helper

setup() {
  setup_test_dir
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOURCE_SCRIPT="$SCRIPT_DIR/scripts/change-default-shell.sh"

  # テスト用 /etc/shells を作る
  SHELLS_FILE_BREW_AND_SYSTEM="$TEST_TEMP_DIR/shells_both"
  cat > "$SHELLS_FILE_BREW_AND_SYSTEM" <<'EOF'
# system shells
/bin/sh
/bin/bash
/bin/zsh
/opt/homebrew/bin/zsh
/opt/homebrew/bin/fish
EOF

  SHELLS_FILE_SYSTEM_ONLY="$TEST_TEMP_DIR/shells_system"
  cat > "$SHELLS_FILE_SYSTEM_ONLY" <<'EOF'
/bin/sh
/bin/bash
/bin/zsh
EOF
}

teardown() {
  teardown_test_dir
}

@test "change-default-shell.sh: NONINTERACTIVE=1 without DOTFILES_DEFAULT_SHELL skips silently" {
  run bash -c "NONINTERACTIVE=1 \"$SOURCE_SCRIPT\" </dev/null 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"NONINTERACTIVE: DOTFILES_DEFAULT_SHELL not set, skipping shell change."* ]]
}

@test "select_shell_noninteractive: prefers brew zsh over /bin/zsh" {
  run bash -c "
    CHANGE_SHELL_LIB_ONLY=1 SHELLS_FILE='$SHELLS_FILE_BREW_AND_SYSTEM' source '$SOURCE_SCRIPT'
    select_shell_noninteractive zsh
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"/opt/homebrew/bin/zsh"* ]]
  [[ "$output" != *"/bin/zsh"$'\n'* ]]
}

@test "select_shell_noninteractive: falls back to /bin/zsh when no brew zsh in /etc/shells" {
  run bash -c "
    CHANGE_SHELL_LIB_ONLY=1 SHELLS_FILE='$SHELLS_FILE_SYSTEM_ONLY' source '$SOURCE_SCRIPT'
    select_shell_noninteractive zsh
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"/bin/zsh"* ]]
}

@test "select_shell_noninteractive: accepts full path input like /bin/zsh" {
  run bash -c "
    CHANGE_SHELL_LIB_ONLY=1 SHELLS_FILE='$SHELLS_FILE_BREW_AND_SYSTEM' source '$SOURCE_SCRIPT'
    select_shell_noninteractive /bin/zsh
  "

  [ "$status" -eq 0 ]
  # basename で正規化されるので brew パスが優先される
  [[ "$output" == *"/opt/homebrew/bin/zsh"* ]]
}

@test "select_shell_noninteractive: returns empty for non-existent shell" {
  run bash -c "
    CHANGE_SHELL_LIB_ONLY=1 SHELLS_FILE='$SHELLS_FILE_SYSTEM_ONLY' source '$SOURCE_SCRIPT'
    # fish は SHELLS_FILE_SYSTEM_ONLY に無い
    result=\$(select_shell_noninteractive nonexistent_shell_xyz)
    [ -z \"\$result\" ] && echo 'EMPTY' || echo \"GOT: \$result\"
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"EMPTY"* ]]
}

@test "change-default-shell.sh: exits 0 when DOTFILES_DEFAULT_SHELL is not found in SHELLS_FILE" {
  run bash -c "
    DOTFILES_DEFAULT_SHELL=nonexistent_shell_xyz \
    SHELLS_FILE='$SHELLS_FILE_SYSTEM_ONLY' \
    '$SOURCE_SCRIPT' </dev/null 2>&1
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"not found"* ]]
  [[ "$output" == *"Skipping"* ]]
}

@test "change-default-shell.sh: rejects non-numeric input without executing it" {
  # 旧実装は選択番号を eval していたため、コマンド注入が可能だった
  run bash -c "SHELLS_FILE='$SHELLS_FILE_SYSTEM_ONLY' '$SOURCE_SCRIPT' <<< '1; echo pwned' 2>&1"

  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid selection"* ]]
  [[ "$output" != *"pwned"* ]]
}

@test "change-default-shell.sh: rejects out-of-range selection" {
  run bash -c "SHELLS_FILE='$SHELLS_FILE_SYSTEM_ONLY' '$SOURCE_SCRIPT' <<< '99' 2>&1"

  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid selection"* ]]
}

@test "change-default-shell.sh: skips brew shell change on ostree-based OS (Bazzite)" {
  # Fedora Atomic では brew シェルへの login shell 変更が公式非推奨のため、
  # 案内を表示してスキップ (exit 0) する
  SHELLS_FILE_WITH_BREW="$TEST_TEMP_DIR/shells_brew"
  cat > "$SHELLS_FILE_WITH_BREW" <<'SHELLS'
/bin/bash
/home/linuxbrew/.linuxbrew/bin/zsh
SHELLS
  OSTREE_MARKER="$TEST_TEMP_DIR/ostree-booted"
  touch "$OSTREE_MARKER"

  run bash -c "
    DOTFILES_DEFAULT_SHELL=zsh \
    SHELLS_FILE='$SHELLS_FILE_WITH_BREW' \
    OSTREE_BOOTED_FILE='$OSTREE_MARKER' \
    '$SOURCE_SCRIPT' </dev/null 2>&1
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping login shell change"* ]]
}

@test "change-default-shell.sh: ostree marker absent proceeds to the change command" {
  # 非 ostree 環境では従来どおり chsh/usermod の実行パスに進む。
  # 実際の sudo/chsh を呼ばないよう sudo をスタブして検証する
  SHELLS_FILE_WITH_BREW="$TEST_TEMP_DIR/shells_brew2"
  cat > "$SHELLS_FILE_WITH_BREW" <<'SHELLS'
/home/linuxbrew/.linuxbrew/bin/zsh
SHELLS
  STUB_DIR="$TEST_TEMP_DIR/stub"
  mkdir -p "$STUB_DIR"
  printf '#!/bin/bash\necho "SUDO_STUB: $*"\nexit 1\n' > "$STUB_DIR/sudo"
  chmod +x "$STUB_DIR/sudo"

  run bash -c "
    PATH='$STUB_DIR':\"\$PATH\" \
    DOTFILES_DEFAULT_SHELL=zsh \
    SHELLS_FILE='$SHELLS_FILE_WITH_BREW' \
    OSTREE_BOOTED_FILE='$TEST_TEMP_DIR/no-such-marker' \
    '$SOURCE_SCRIPT' </dev/null 2>&1
  "

  # スキップされず、変更コマンド (スタブ sudo) に到達している
  [ "$status" -eq 1 ]
  [[ "$output" == *"SUDO_STUB:"* ]]
  [[ "$output" != *"Skipping login shell change"* ]]
}
