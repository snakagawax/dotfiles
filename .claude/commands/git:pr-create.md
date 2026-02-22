---
description: コミット履歴からPRを自動作成
allowed-tools: ["Bash(git:*)", "Bash(gh:*)"]
---

# PR作成

コミット履歴を分析し、PRを自動作成します。

## 厳守事項

- NEVER push to main/master directly
- NEVER create PR without user confirmation
- リポジトリのPRテンプレートがあれば従う

## 引数

`$ARGUMENTS`

| 入力 | 動作 |
|------|------|
| （空） | 現在のブランチからPRを作成 |
| `--draft` | ドラフトPRとして作成 |
| `--base <branch>` | ベースブランチ指定（デフォルト: main/master自動検出） |
| `--ja` | 日本語でPR本文生成 |
| `--en` | 英語でPR本文生成 |

複数オプションの組み合わせ可能: `/git:pr-create --draft --base develop`

---

## Step 1: 事前チェック

以下を確認:

```bash
git status
git branch --show-current
git remote -v
```

### チェック項目

1. **未コミットの変更がないか**
   - ある場合: 警告を表示し、先にコミットするか確認

2. **リモートが設定されているか**
   - ない場合: エラー終了

3. **現在のブランチがmain/masterでないか**
   - main/masterの場合: 警告を表示

---

## Step 2: ベースブランチの決定

`--base` 指定がない場合、以下の順で自動検出:

1. `git symbolic-ref refs/remotes/origin/HEAD` でデフォルトブランチを取得
2. 取得できない場合: `main` → `master` の順で存在確認
3. いずれもない場合: ユーザーに確認

---

## Step 3: コミット履歴の分析

```bash
git log --oneline <base-branch>..HEAD
git diff <base-branch>...HEAD --stat
```

### 分析項目

1. **言語判定**（`--ja`/`--en` 指定時はスキップ）
   - コミットメッセージの言語を判定

2. **変更の種類**
   - feat/fix/refactor等のプレフィックスを検出
   - 主な変更内容を把握

3. **影響範囲**
   - 変更ファイル数、追加/削除行数

---

## Step 4: PRタイトル生成

### フォーマット

コミットが1つの場合:
```
<type>(<scope>): <subject>
```

コミットが複数の場合:
```
<主要な変更を要約>
```

### 例

```
feat(auth): add MFA support to login
fix: resolve memory leak in worker process
refactor: migrate from REST to GraphQL
```

---

## Step 5: PR本文生成

### フォーマット

```markdown
## Summary
<変更の概要を1-3文で>

## Changes
- <変更点1>
- <変更点2>
- <変更点3>

## Test plan
- [ ] <テスト項目1>
- [ ] <テスト項目2>
```

### 日本語の場合

```markdown
## 概要
<変更の概要を1-3文で>

## 変更内容
- <変更点1>
- <変更点2>

## テスト計画
- [ ] <テスト項目1>
- [ ] <テスト項目2>
```

---

## Step 6: ユーザー確認

PR作成前に確認を表示:

```
📋 PR作成内容:

ブランチ: feature/mfa-support → main
タイトル: feat(auth): add MFA support to login

本文:
---
## Summary
Add multi-factor authentication support to the login flow.

## Changes
- Implement TOTP authentication
- Add backup code generation
- Update login UI for MFA input

## Test plan
- [ ] Test login with MFA enabled
- [ ] Test backup code usage
---

この内容でPRを作成しますか？
```

---

## Step 7: PR作成

ユーザーの承認後、PR作成を実行:

```bash
gh pr create --title "<タイトル>" --body "<本文>" [--draft] [--base <branch>]
```

---

## Step 8: 完了報告

```
✅ PRを作成しました

🔗 URL: https://github.com/owner/repo/pull/123

📋 詳細:
- タイトル: feat(auth): add MFA support to login
- ブランチ: feature/mfa-support → main
- ステータス: Open / Draft
```

---

## エラーハンドリング

### gh CLIがインストールされていない場合

```
❌ エラー: gh (GitHub CLI) がインストールされていません

インストール方法:
- macOS: brew install gh
- その他: https://cli.github.com/

インストール後、`gh auth login` で認証してください。
```

### 認証されていない場合

```
❌ エラー: GitHub CLIが認証されていません

以下を実行してください:
gh auth login
```

### プッシュされていない場合

```
⚠️ 現在のブランチがリモートにプッシュされていません

プッシュしてからPRを作成しますか？
```

「はい」の場合: `git push -u origin <branch>` を実行してからPR作成
