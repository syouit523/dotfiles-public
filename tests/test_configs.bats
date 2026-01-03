#!/usr/bin/env bats

# Tests for configuration files syntax validation

load test_helper

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

# Test shell script syntax
@test "all shell scripts have valid syntax" {
  local failed=0
  local scripts=()

  # Find all .sh files
  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find "$SCRIPT_DIR/scripts" -name "*.sh" -type f -print0)

  for script in "${scripts[@]}"; do
    if ! bash -n "$script"; then
      echo "Syntax error in: $script"
      failed=1
    fi
  done

  [ $failed -eq 0 ]
}

# Test Zsh configuration syntax
@test "zsh configuration files have valid syntax" {
  # Skip if zsh is not available
  if ! command -v zsh &> /dev/null; then
    skip "zsh is not installed"
  fi

  local failed=0
  local zsh_files=()

  # Find all .zsh and zshrc files
  while IFS= read -r -d '' file; do
    zsh_files+=("$file")
  done < <(find "$SCRIPT_DIR/configs/zsh" -type f \( -name "*.zsh" -o -name "zshrc" \) -print0 2>/dev/null)

  for file in "${zsh_files[@]}"; do
    if ! zsh -n "$file" 2>/dev/null; then
      echo "Syntax error in: $file"
      failed=1
    fi
  done

  [ $failed -eq 0 ]
}

# Test Git configuration syntax
@test "git configuration file is valid" {
  local gitconfig="$SCRIPT_DIR/configs/git/gitconfig"

  if [ ! -f "$gitconfig" ]; then
    skip "gitconfig not found"
  fi

  # Try to parse the gitconfig file
  run git config -f "$gitconfig" --list

  [ "$status" -eq 0 ]
}

# Test tmux configuration syntax
@test "tmux configuration file is valid" {
  # Skip if tmux is not available
  if ! command -v tmux &> /dev/null; then
    skip "tmux is not installed"
  fi

  local tmux_conf="$SCRIPT_DIR/configs/tmux/tmux.conf"

  if [ ! -f "$tmux_conf" ]; then
    skip "tmux.conf not found"
  fi

  # Verify tmux can parse the configuration
  run tmux -f "$tmux_conf" list-commands

  [ "$status" -eq 0 ]
}

# Test Brewfile syntax
@test "Brewfiles are valid" {
  local failed=0
  local brewfiles=()

  # Find all Brewfile files
  while IFS= read -r -d '' brewfile; do
    brewfiles+=("$brewfile")
  done < <(find "$SCRIPT_DIR/Brewfiles" -name "*Brewfile" -type f -print0 2>/dev/null)

  if [ ${#brewfiles[@]} -eq 0 ]; then
    skip "No Brewfiles found"
  fi

  for brewfile in "${brewfiles[@]}"; do
    # Basic syntax check: ensure file is not empty and has valid Ruby-like syntax
    if [ ! -s "$brewfile" ]; then
      echo "Empty Brewfile: $brewfile"
      failed=1
      continue
    fi

    # Check for basic Brewfile syntax (tap, brew, cask)
    if ! grep -qE '^(tap|brew|cask|mas)' "$brewfile"; then
      echo "Invalid Brewfile syntax: $brewfile"
      failed=1
    fi
  done

  [ $failed -eq 0 ]
}

# Test for common issues
@test "no shell scripts have Windows line endings" {
  local failed=0
  local scripts=()

  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find "$SCRIPT_DIR/scripts" -name "*.sh" -type f -print0)

  for script in "${scripts[@]}"; do
    if file "$script" | grep -q "CRLF"; then
      echo "Windows line endings found in: $script"
      failed=1
    fi
  done

  [ $failed -eq 0 ]
}

# Test script permissions
@test "all shell scripts in scripts/ are executable" {
  local failed=0
  local scripts=()

  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find "$SCRIPT_DIR/scripts" -name "*.sh" -type f -print0)

  for script in "${scripts[@]}"; do
    if [ ! -x "$script" ]; then
      echo "Not executable: $script"
      failed=1
    fi
  done

  [ $failed -eq 0 ]
}

# Test that test files themselves are valid
@test "test files have valid BATS syntax" {
  local failed=0
  local test_files=()

  while IFS= read -r -d '' test_file; do
    test_files+=("$test_file")
  done < <(find "$SCRIPT_DIR/tests" -name "*.bats" -type f -not -path "*/\.bats/*" -print0)

  for test_file in "${test_files[@]}"; do
    # Check for basic BATS test structure
    if ! grep -q "@test" "$test_file"; then
      echo "No @test directive found in: $test_file"
      failed=1
    fi
  done

  [ $failed -eq 0 ]
}
