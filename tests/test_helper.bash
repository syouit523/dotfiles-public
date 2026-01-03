#!/bin/bash

# Common test helper functions for BATS tests

# Setup temporary test directory
setup_test_dir() {
  TEST_TEMP_DIR="$(mktemp -d -t dotfiles-test-XXXXXX)"
  export TEST_TEMP_DIR
}

# Cleanup temporary test directory
teardown_test_dir() {
  if [ -n "$TEST_TEMP_DIR" ] && [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}

# Create a test file with content
create_test_file() {
  local file_path="$1"
  local content="${2:-test content}"
  mkdir -p "$(dirname "$file_path")"
  echo "$content" > "$file_path"
}

# Check if file is a symlink pointing to expected target
assert_symlink_to() {
  local link="$1"
  local expected_target="$2"

  [ -L "$link" ] || return 1
  local actual_target="$(readlink "$link")"
  [ "$actual_target" = "$expected_target" ] || return 1
}

# Assert file exists
assert_file_exists() {
  [ -f "$1" ]
}

# Assert directory exists
assert_dir_exists() {
  [ -d "$1" ]
}

# Assert file does not exist
assert_file_not_exists() {
  [ ! -e "$1" ]
}

# Get file content
get_file_content() {
  cat "$1"
}
