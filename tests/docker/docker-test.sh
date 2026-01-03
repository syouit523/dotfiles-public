#!/bin/bash

# Docker環境でテストを実行するスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

echo "Building Docker test image..."
docker build -f tests/docker/Dockerfile.test -t dotfiles-test .

echo ""
echo "Running tests in Docker container..."
docker run --rm -v "$REPO_ROOT":/workspace dotfiles-test

echo ""
echo "All tests completed successfully!"
