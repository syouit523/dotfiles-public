#!/usr/bin/env bats

# Tests for git-clone.sh

load test_helper

setup() {
  setup_test_dir
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOURCE_SCRIPT="$SCRIPT_DIR/scripts/git-clone.sh"

  # Change to test directory
  cd "$TEST_TEMP_DIR"
}

teardown() {
  teardown_test_dir
}

@test "git-clone.sh: exits with error when no arguments provided" {
  run "$SOURCE_SCRIPT"

  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "git-clone.sh: shows usage message with repository_url parameter" {
  run "$SOURCE_SCRIPT"

  [ "$status" -eq 1 ]
  [[ "$output" == *"<repository_url>"* ]]
}

@test "git-clone.sh: creates deps directory" {
  # Use a lightweight public repo for testing
  skip "Skipping actual git clone test - requires network"

  run "$SOURCE_SCRIPT" "https://github.com/git/git.git"

  assert_dir_exists "$TEST_TEMP_DIR/deps"
}

@test "git-clone.sh: extracts repository name from HTTPS URL" {
  # Mock git clone to avoid network dependency
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      return 0
    fi
  }
  export -f git

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/test-repo.git"

  [ "$status" -eq 0 ]
  assert_dir_exists "$TEST_TEMP_DIR/deps/test-repo"
}

@test "git-clone.sh: extracts repository name from SSH URL" {
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      return 0
    fi
  }
  export -f git

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "git@github.com:user/test-repo.git"

  [ "$status" -eq 0 ]
  assert_dir_exists "$TEST_TEMP_DIR/deps/test-repo"
}

@test "git-clone.sh: creates symbolic link when link_directory is provided" {
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      echo "test" > "$3/README.md"
      return 0
    fi
  }
  export -f git

  local link_dir="$TEST_TEMP_DIR/.config/test-repo"

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/test-repo.git" "$link_dir"

  [ "$status" -eq 0 ]
  assert_symlink_to "$link_dir" "$TEST_TEMP_DIR/deps/test-repo"
}

@test "git-clone.sh: creates parent directory for symbolic link if needed" {
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      return 0
    fi
  }
  export -f git

  local link_dir="$TEST_TEMP_DIR/nested/dirs/.config/test-repo"

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/test-repo.git" "$link_dir"

  [ "$status" -eq 0 ]
  assert_dir_exists "$TEST_TEMP_DIR/nested/dirs/.config"
  assert_symlink_to "$link_dir" "$TEST_TEMP_DIR/deps/test-repo"
}

@test "git-clone.sh: removes existing repository before cloning" {
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      echo "new" > "$3/file.txt"
      return 0
    fi
  }
  export -f git

  # Create old repository
  mkdir -p "$TEST_TEMP_DIR/deps/test-repo"
  echo "old" > "$TEST_TEMP_DIR/deps/test-repo/file.txt"

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/test-repo.git"

  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_TEMP_DIR/deps/test-repo/file.txt")" = "new" ]
}

@test "git-clone.sh: exits with error when git clone fails" {
  function git() {
    if [ "$1" = "clone" ]; then
      echo "fatal: repository not found"
      return 1
    fi
  }
  export -f git

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/nonexistent-repo.git"

  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to clone repository"* ]]
}

@test "git-clone.sh: sets CLONED_DIR_PATH environment variable" {
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      return 0
    fi
  }
  export -f git

  run bash -c "GIT_CLONE_BASE_DIR='$TEST_TEMP_DIR' source '$SOURCE_SCRIPT' https://github.com/user/test-repo.git > /dev/null 2>&1; echo \$CLONED_DIR_PATH"

  [[ "$output" == *"/deps/test-repo"* ]]
}

@test "git-clone.sh: uses --depth 1 for shallow clone" {
  # Capture git command arguments
  function git() {
    echo "$@" >> "$TEST_TEMP_DIR/git_commands.log"
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      return 0
    fi
  }
  export -f git

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/test-repo.git"

  [ "$status" -eq 0 ]
  grep -q "clone.*--depth 1" "$TEST_TEMP_DIR/git_commands.log"
}

@test "git-clone.sh: sets correct permissions on deps directory" {
  function git() {
    if [ "$1" = "clone" ]; then
      mkdir -p "$3"
      return 0
    fi
  }
  export -f git

  run env GIT_CLONE_BASE_DIR="$TEST_TEMP_DIR" "$SOURCE_SCRIPT" "https://github.com/user/test-repo.git"

  [ "$status" -eq 0 ]
  assert_dir_exists "$TEST_TEMP_DIR/deps"
  # Check permissions (755 = rwxr-xr-x)
  [ "$(stat -c %a "$TEST_TEMP_DIR/deps")" = "755" ] || [ "$(stat -f %A "$TEST_TEMP_DIR/deps" 2>/dev/null)" = "755" ]
}
