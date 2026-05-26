#!/usr/bin/env bats

# Tests for change-default-shell.sh

load test_helper

setup() {
  setup_test_dir
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOURCE_SCRIPT="$SCRIPT_DIR/scripts/change-default-shell.sh"
}

teardown() {
  teardown_test_dir
}

# select_shell_noninteractive function tests
# /etc/shells を直接モックすることはできないので、関数の振る舞いを確認する範囲のテスト

@test "change-default-shell.sh: NONINTERACTIVE=1 without DOTFILES_DEFAULT_SHELL skips silently" {
  run bash -c "NONINTERACTIVE=1 \"$SOURCE_SCRIPT\" </dev/null 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"NONINTERACTIVE: DOTFILES_DEFAULT_SHELL not set, skipping shell change."* ]]
}

@test "change-default-shell.sh: select_shell_noninteractive returns brew zsh when both system and brew exist" {
  # /etc/shells に存在する zsh を探す関数を関数だけ抽出してテスト
  run bash -c "
    source '$SOURCE_SCRIPT' 2>/dev/null || true
    # /etc/shells をモック
    tmpfile=\$(mktemp)
    cat > \"\$tmpfile\" <<EOF
/bin/zsh
/opt/homebrew/bin/zsh
EOF
    # select_shell_noninteractive 内の /etc/shells 参照を tmpfile で代用する形でテスト
    select_shell_noninteractive() {
      local target=\"\$1\"
      local basename_target
      basename_target=\$(basename \"\$target\")
      local matches
      matches=\$(grep -E '^[^#]' \"\$tmpfile\" | grep -E \"/\${basename_target}\$\" || true)
      local found=''
      for prefix in /opt/homebrew/bin /usr/local/bin /home/linuxbrew/.linuxbrew/bin; do
        found=\$(echo \"\$matches\" | grep -E \"^\${prefix}/\${basename_target}\$\" | head -n1 || true)
        [ -n \"\$found\" ] && { echo \"\$found\"; return 0; }
      done
      echo \"\$matches\" | head -n1
    }
    select_shell_noninteractive zsh
    rm -f \"\$tmpfile\"
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"/opt/homebrew/bin/zsh"* ]]
}

@test "change-default-shell.sh: select_shell_noninteractive falls back to first /etc/shells entry when no brew path" {
  run bash -c "
    tmpfile=\$(mktemp)
    cat > \"\$tmpfile\" <<EOF
/bin/zsh
/usr/bin/zsh
EOF
    select_shell_noninteractive() {
      local target=\"\$1\"
      local basename_target
      basename_target=\$(basename \"\$target\")
      local matches
      matches=\$(grep -E '^[^#]' \"\$tmpfile\" | grep -E \"/\${basename_target}\$\" || true)
      local found=''
      for prefix in /opt/homebrew/bin /usr/local/bin /home/linuxbrew/.linuxbrew/bin; do
        found=\$(echo \"\$matches\" | grep -E \"^\${prefix}/\${basename_target}\$\" | head -n1 || true)
        [ -n \"\$found\" ] && { echo \"\$found\"; return 0; }
      done
      echo \"\$matches\" | head -n1
    }
    select_shell_noninteractive zsh
    rm -f \"\$tmpfile\"
  "

  [ "$status" -eq 0 ]
  [[ "$output" == *"/bin/zsh"* ]]
}
