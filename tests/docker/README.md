# Docker テスト環境

このディレクトリには、Dockerを使用してローカルでCI/CDテストを実行するためのファイルが含まれています。

## 使用方法

### 前提条件
- Dockerがインストールされていること

### テストの実行

**推奨: Makeコマンドを使用**

```bash
# リポジトリのルートから
make docker-test
# または短縮形
make dt
```

**直接スクリプトを実行**

```bash
# tests/docker ディレクトリに移動
cd tests/docker

# テストを実行
./docker-test.sh
```

または、リポジトリのルートから：

```bash
./tests/docker/docker-test.sh
```

### その他のコマンド

```bash
# Dockerイメージをビルドのみ
make docker-build

# テストアーティファクトをクリーンアップ
make test-clean
```

## ファイル構成

- `Dockerfile.test` - テスト用のDockerイメージ定義
- `docker-test.sh` - テスト実行スクリプト
- `.dockerignore` - Docker ビルド時に除外するファイル
- `README.md` - このファイル

## テスト内容

以下のテストが実行されます：

1. **BATS テスト**
   - test_configs.bats
   - test_deploy_configs.bats
   - test_git_clone.bats
   - test_setup_gitconfig.bats

2. **shellcheck**
   - 全てのシェルスクリプトの静的解析

## 注意事項

- Dockerコンテナ内ではUbuntu環境でテストが実行されます
- macOS固有の機能はテストされません
- GitHub Actionsと同じUbuntu環境を再現します
