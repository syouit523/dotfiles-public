#!/usr/bin/env bats

# Tests for deploy-configs.sh

load test_helper

setup() {
  setup_test_dir
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOURCE_SCRIPT="$SCRIPT_DIR/scripts/deploy-configs.sh"

  # Create test configs directory
  TEST_ROOT="$TEST_TEMP_DIR/dotfiles"
  TEST_CONFIGS="$TEST_ROOT/configs"
  mkdir -p "$TEST_CONFIGS"

  # Create test home directory
  TEST_HOME="$TEST_TEMP_DIR/home"
  mkdir -p "$TEST_HOME"
  export HOME="$TEST_HOME"
}

teardown() {
  teardown_test_dir
}

# Test mode_file function with link mode
@test "mode_file: link mode creates symlink when target does not exist" {
  source "$SOURCE_SCRIPT" link "$TEST_ROOT"

  local source_file="$TEST_TEMP_DIR/source.txt"
  local target_file="$TEST_TEMP_DIR/target.txt"
  create_test_file "$source_file" "test content"

  mode_file "$source_file" "$target_file"

  assert_symlink_to "$target_file" "$source_file"
}

@test "mode_file: link mode creates backup when target exists and is not a symlink" {
  source "$SOURCE_SCRIPT" link "$TEST_ROOT"

  local source_file="$TEST_TEMP_DIR/source.txt"
  local target_file="$TEST_TEMP_DIR/target.txt"
  create_test_file "$source_file" "new content"
  create_test_file "$target_file" "old content"

  mode_file "$source_file" "$target_file"

  assert_symlink_to "$target_file" "$source_file"
  assert_file_exists "$TEST_TEMP_DIR/target.txt.backup"
  [ "$(get_file_content "$TEST_TEMP_DIR/target.txt.backup")" = "old content" ]
}

@test "mode_file: link mode does not create duplicate link if already linked correctly" {
  source "$SOURCE_SCRIPT" link "$TEST_ROOT"

  local source_file="$TEST_TEMP_DIR/source.txt"
  local target_file="$TEST_TEMP_DIR/target.txt"
  create_test_file "$source_file" "test content"
  ln -s "$source_file" "$target_file"

  run mode_file "$source_file" "$target_file"

  [ "$status" -eq 0 ]
  [[ "$output" == *"already linked"* ]]
}

@test "mode_file: copy mode copies file and creates backup" {
  source "$SOURCE_SCRIPT" copy "$TEST_ROOT"

  local source_file="$TEST_TEMP_DIR/source.txt"
  local target_file="$TEST_TEMP_DIR/target.txt"
  create_test_file "$source_file" "new content"
  create_test_file "$target_file" "old content"

  mode_file "$source_file" "$target_file"

  assert_file_exists "$target_file"
  [ ! -L "$target_file" ]  # Should not be a symlink
  [ "$(get_file_content "$target_file")" = "new content" ]
  assert_file_exists "$TEST_TEMP_DIR/target.txt.backup"
  [ "$(get_file_content "$TEST_TEMP_DIR/target.txt.backup")" = "old content" ]
}

@test "mode_file: delete mode removes file and restores backup" {
  source "$SOURCE_SCRIPT" delete "$TEST_ROOT"

  local target_file="$TEST_TEMP_DIR/target.txt"
  local backup_file="$TEST_TEMP_DIR/target.txt.backup"
  create_test_file "$target_file" "current content"
  create_test_file "$backup_file" "backup content"

  run mode_file "" "$target_file"

  [ "$status" -eq 0 ]
  assert_file_exists "$target_file"
  [ "$(get_file_content "$target_file")" = "backup content" ]
  assert_file_not_exists "$backup_file"
}

@test "mode_file: delete mode handles non-existent file gracefully" {
  source "$SOURCE_SCRIPT" delete "$TEST_ROOT"

  local target_file="$TEST_TEMP_DIR/nonexistent.txt"

  run mode_file "" "$target_file"

  [ "$status" -eq 0 ]
  [[ "$output" == *"file not found"* ]]
}

# Test mode_directory function
@test "mode_directory: links all files in directory recursively" {
  source "$SOURCE_SCRIPT" link "$TEST_ROOT"

  local source_dir="$TEST_TEMP_DIR/source_dir"
  local target_dir="$TEST_TEMP_DIR/target_dir"

  mkdir -p "$source_dir/subdir"
  create_test_file "$source_dir/file1.txt" "content1"
  create_test_file "$source_dir/file2.txt" "content2"
  create_test_file "$source_dir/subdir/file3.txt" "content3"

  mode_directory "$source_dir" "$target_dir"

  assert_symlink_to "$target_dir/file1.txt" "$source_dir/file1.txt"
  assert_symlink_to "$target_dir/file2.txt" "$source_dir/file2.txt"
  assert_symlink_to "$target_dir/subdir/file3.txt" "$source_dir/subdir/file3.txt"
}

@test "mode_directory: creates target directory if it does not exist" {
  source "$SOURCE_SCRIPT" link "$TEST_ROOT"

  local source_dir="$TEST_TEMP_DIR/source_dir"
  local target_dir="$TEST_TEMP_DIR/nested/target_dir"

  mkdir -p "$source_dir"
  create_test_file "$source_dir/file.txt" "content"

  mode_directory "$source_dir" "$target_dir"

  assert_dir_exists "$target_dir"
  assert_symlink_to "$target_dir/file.txt" "$source_dir/file.txt"
}

# Test script argument validation
@test "deploy-configs.sh: exits with error when no arguments provided" {
  run "$SOURCE_SCRIPT"

  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "deploy-configs.sh: exits with error when only mode is provided" {
  run "$SOURCE_SCRIPT" link

  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "deploy-configs.sh: accepts valid link mode with root directory" {
  # Create minimal configs directory structure
  mkdir -p "$TEST_CONFIGS/git"
  create_test_file "$TEST_CONFIGS/git/gitignore_global" "*.log"

  # Mock interactive input for deploy_git
  run bash -c "echo 'n' | \"$SOURCE_SCRIPT\" link \"$TEST_ROOT\""

  assert_equal "$status" 0
}

@test "deploy-configs.sh: accepts valid copy mode with root directory" {
  mkdir -p "$TEST_CONFIGS/vim"
  create_test_file "$TEST_CONFIGS/vim/vimrc" "set number"

  run "$SOURCE_SCRIPT" copy "$TEST_ROOT"

  [ "$status" -eq 0 ]
}

@test "deploy-configs.sh: accepts valid delete mode with root directory" {
  mkdir -p "$TEST_CONFIGS/tmux"
  create_test_file "$TEST_CONFIGS/tmux/tmux.conf" "set -g mouse on"

  run "$SOURCE_SCRIPT" delete "$TEST_ROOT"

  [ "$status" -eq 0 ]
}
