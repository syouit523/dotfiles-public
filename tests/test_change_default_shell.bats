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
