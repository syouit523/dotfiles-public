#!/usr/bin/env bats

# Tests for setup-gitconfig.sh

load test_helper

setup() {
  setup_test_dir
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOURCE_SCRIPT="$SCRIPT_DIR/scripts/setup-gitconfig.sh"

  # Setup fake git repository with commit history
  cd "$TEST_TEMP_DIR"
  git init
  git config user.name "Test User"
  git config user.email "test@example.com"
  echo "test" > test.txt
  git add test.txt
  git commit -m "Initial commit"

  # Setup fake HOME for git config
  TEST_HOME="$TEST_TEMP_DIR/home"
  mkdir -p "$TEST_HOME"
  export HOME="$TEST_HOME"
}

teardown() {
  cd /
  teardown_test_dir
}

@test "setup-gitconfig.sh: reads author name from git log" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1 | grep -o 'Test User'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Test User"* ]]
}

@test "setup-gitconfig.sh: reads author email from git log" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1 | grep -o 'test@example.com'"

  [ "$status" -eq 0 ]
  [[ "$output" == *"test@example.com"* ]]
}

@test "setup-gitconfig.sh: prompts user to change name and email" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Do you want to change"* ]]
}

@test "setup-gitconfig.sh: uses existing values when user chooses not to change" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Using existing"* ]]

  # Check git config was set
  local configured_name=$(git config --global user.name)
  local configured_email=$(git config --global user.email)

  [ "$configured_name" = "Test User" ]
  [ "$configured_email" = "test@example.com" ]
}

@test "setup-gitconfig.sh: allows user to change name and email" {
  run bash -c "source '$SOURCE_SCRIPT' <<< \$'y\nNew User\nnew@example.com' 2>&1"

  [ "$status" -eq 0 ]

  # Check git config was set with new values
  local configured_name=$(git config --global user.name)
  local configured_email=$(git config --global user.email)

  [ "$configured_name" = "New User" ]
  [ "$configured_email" = "new@example.com" ]
}

@test "setup-gitconfig.sh: displays changed values when user modifies them" {
  run bash -c "source '$SOURCE_SCRIPT' <<< \$'y\nCustom Name\ncustom@example.com' 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Changed Author Name: Custom Name"* ]]
  [[ "$output" == *"Changed Author Email: custom@example.com"* ]]
}

@test "setup-gitconfig.sh: uses default value when user enters empty input" {
  # Simulate user pressing enter without input (accepts default)
  run bash -c "source '$SOURCE_SCRIPT' <<< \$'y\n\n' 2>&1"

  [ "$status" -eq 0 ]

  local configured_name=$(git config --global user.name)
  local configured_email=$(git config --global user.email)

  [ "$configured_name" = "Test User" ]
  [ "$configured_email" = "test@example.com" ]
}

@test "setup-gitconfig.sh: displays completion message" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Completed gitconfig setting"* ]]
}

@test "setup-gitconfig.sh: accepts uppercase Y for yes" {
  run bash -c "source '$SOURCE_SCRIPT' <<< \$'Y\nNew User\nnew@example.com' 2>&1"

  [ "$status" -eq 0 ]

  local configured_name=$(git config --global user.name)

  [ "$configured_name" = "New User" ]
}

@test "setup-gitconfig.sh: displays git configuration prompt with colors" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Configure Git settings"* ]]
}

@test "setup-gitconfig.sh: sets git config globally" {
  run bash -c "source '$SOURCE_SCRIPT' <<< 'n' 2>&1"

  [ "$status" -eq 0 ]

  # Verify config is set globally (in HOME/.gitconfig)
  assert_file_exists "$HOME/.gitconfig"

  local global_name=$(git config --global user.name)
  local global_email=$(git config --global user.email)

  [ -n "$global_name" ]
  [ -n "$global_email" ]
}
