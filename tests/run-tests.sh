#!/bin/bash

# Test runner script for dotfiles tests
# This script installs BATS if needed and runs all tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS_VERSION="v1.11.0"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Check if bats is installed
check_bats_installed() {
  if command -v bats &> /dev/null; then
    echo -e "${GREEN}✓ BATS is already installed${RESET}"
    return 0
  else
    echo -e "${YELLOW}! BATS is not installed${RESET}"
    return 1
  fi
}

# Install BATS using git
install_bats() {
  echo -e "${YELLOW}Installing BATS test framework...${RESET}"

  local install_dir="$SCRIPT_DIR/.bats"

  if [ -d "$install_dir" ]; then
    echo "Removing existing BATS installation..."
    rm -rf "$install_dir"
  fi

  mkdir -p "$install_dir"

  # Clone BATS core
  # NOTE: bats-support / bats-assert / bats-file はどのテストからも
  # 使われていない (test_helper.bash が自前の assert を持つ) ため clone しない
  echo "Cloning BATS core..."
  git clone --depth 1 --branch "$BATS_VERSION" https://github.com/bats-core/bats-core.git "$install_dir/bats-core"

  echo -e "${GREEN}✓ BATS installed successfully${RESET}"
}

# Run tests
run_tests() {
  local bats_bin

  if command -v bats &> /dev/null; then
    bats_bin="bats"
  else
    bats_bin="$SCRIPT_DIR/.bats/bats-core/bin/bats"
  fi

  if [ ! -x "$bats_bin" ] && [ ! -f "$bats_bin" ]; then
    echo -e "${RED}✗ BATS executable not found at $bats_bin${RESET}"
    exit 1
  fi

  echo -e "${YELLOW}Running tests...${RESET}"
  echo ""

  # Run all .bats test files
  # nullglob: マッチなしのときリテラル "*.bats" が残らないようにする
  shopt -s nullglob
  local test_files=("$SCRIPT_DIR"/*.bats)
  shopt -u nullglob

  if [ ${#test_files[@]} -eq 0 ]; then
    echo -e "${YELLOW}! No test files found${RESET}"
    exit 0
  fi

  local failed=0
  for test_file in "${test_files[@]}"; do
    if [ -f "$test_file" ]; then
      echo -e "${YELLOW}Running $(basename "$test_file")...${RESET}"
      if "$bats_bin" "$test_file"; then
        echo -e "${GREEN}✓ $(basename "$test_file") passed${RESET}"
      else
        echo -e "${RED}✗ $(basename "$test_file") failed${RESET}"
        failed=1
      fi
      echo ""
    fi
  done

  if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${RESET}"
    return 0
  else
    echo -e "${RED}✗ Some tests failed${RESET}"
    return 1
  fi
}

# Main
main() {
  echo "Dotfiles Test Runner"
  echo "===================="
  echo ""

  if ! check_bats_installed; then
    install_bats
  fi

  # --install-only: BATS のインストールだけ行い、テストは実行しない
  if [ "${1:-}" = "--install-only" ]; then
    echo -e "${GREEN}✓ Install-only mode: skipping test run${RESET}"
    return 0
  fi

  run_tests
}

main "$@"
