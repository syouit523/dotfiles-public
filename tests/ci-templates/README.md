# CI/CD テンプレート

このディレクトリには、GitHub ActionsなどのCI/CDシステム用のテンプレートファイルが含まれています。

## GitHub Actions ワークフロー

### セットアップ方法

GitHub Actionsを有効にするには、以下のコマンドを実行してください：

```bash
# .github/workflows ディレクトリを作成
mkdir -p .github/workflows

# テンプレートをコピー
cp tests/ci-templates/github-actions-test.yml .github/workflows/test.yml

# Git に追加してコミット
git add .github/workflows/test.yml
git commit -m "Add GitHub Actions workflow for testing"
git push
```

### ワークフローの内容

`github-actions-test.yml` ワークフローは以下を実行します：

1. **テスト実行**（Ubuntu と macOS で並列実行）
   - BATSフレームワークを自動インストール
   - すべてのテストケースを実行
   - テスト結果をアーティファクトとして保存

2. **静的解析**（Ubuntu）
   - ShellCheckによるシェルスクリプトの静的解析
   - スクリプトの実行権限チェック

### トリガー条件

ワークフローは以下の場合に自動実行されます：

- `main` ブランチへのプッシュ
- `claude/**` ブランチへのプッシュ
- `main` ブランチへのプルリクエスト
- 手動トリガー（workflow_dispatch）

## 注意事項

GitHub Appの権限制限により、`.github/workflows/` 配下のファイルは自動的に作成できません。
そのため、テンプレートファイルを手動でコピーして配置する必要があります。
