---
description: PRに出す前のコードレビュー（バグ・セキュリティ・パフォーマンス）
allowed-tools: ["Read(**)", "Bash(git:*)"]
---

# コードレビュー

変更内容をレビューし、問題点と改善提案を提示します。

## 引数

`$ARGUMENTS`

| 入力 | 動作 |
|------|------|
| （空） | ステージ済み差分をレビュー |
| `<ファイルパス>` | 指定ファイルをレビュー |
| `--all` | 全変更（ステージ済み+未ステージ）をレビュー |
| `--focus security` | セキュリティ観点に絞る |
| `--focus performance` | パフォーマンス観点に絞る |
| `--focus bug` | バグ検出に絞る |

複数オプション組み合わせ可能: `/git:review src/auth.ts --focus security`

---

## Step 1: レビュー対象の取得

### 引数なしの場合

```bash
git diff --staged
```

ステージ済みがない場合:
```bash
git diff
```

### ファイルパス指定の場合

Readツールで直接ファイルを読み込み

### --all 指定の場合

```bash
git diff HEAD
```

---

## Step 2: 変更の概要把握

```bash
git diff --stat [対象]
```

変更ファイル数、追加/削除行数を確認

---

## Step 3: レビュー実行

以下の観点でレビュー:

### 3-1: バグ検出

| チェック項目 | 例 |
|-------------|-----|
| null/undefined参照 | `obj.prop` without null check |
| 境界値エラー | off-by-one, array bounds |
| 型の不整合 | string vs number comparison |
| 例外処理漏れ | unhandled promise rejection |
| ロジックエラー | wrong condition, infinite loop |
| リソースリーク | unclosed connection, file handle |

### 3-2: セキュリティ

| チェック項目 | 例 |
|-------------|-----|
| 入力検証不足 | SQL injection, XSS |
| 認証・認可漏れ | missing auth check |
| 機密情報露出 | hardcoded secrets, logging sensitive data |
| 安全でない依存 | known vulnerable packages |
| CSRF対策 | missing token validation |
| パス traversal | unsanitized file paths |

### 3-3: パフォーマンス

| チェック項目 | 例 |
|-------------|-----|
| N+1クエリ | loop内でのDB呼び出し |
| 不要な計算 | 再計算可能な値のキャッシュ漏れ |
| メモリ効率 | large object in memory |
| 非効率なアルゴリズム | O(n²) when O(n) possible |
| 不要なリレンダリング | React memo漏れ |

### 3-4: 可読性・保守性

| チェック項目 | 例 |
|-------------|-----|
| 命名の適切さ | unclear variable names |
| 関数の長さ | functions > 50 lines |
| 重複コード | DRY violation |
| マジックナンバー | hardcoded values |
| コメント不足 | complex logic without explanation |

---

## Step 4: 問題の分類

検出した問題を重要度で分類:

| レベル | 説明 | アイコン |
|--------|------|---------|
| Critical | 本番障害・セキュリティ脆弱性 | 🔴 |
| Warning | 潜在的なバグ・パフォーマンス問題 | 🟡 |
| Info | 改善提案・ベストプラクティス | 🔵 |

---

## Step 5: レビュー結果出力

### フォーマット

```
📝 コードレビュー結果

📊 サマリー:
- 変更ファイル: 5
- 追加: +120行 / 削除: -45行
- 検出: 🔴 1件 / 🟡 3件 / 🔵 2件

---

🔴 Critical (1件)

### src/api/auth.ts:45
SQL Injection の可能性

```typescript
// 問題のコード
const query = `SELECT * FROM users WHERE id = ${userId}`;
```

**問題**: ユーザー入力が直接SQLに埋め込まれています
**修正案**:
```typescript
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```

---

🟡 Warning (3件)

### src/services/payment.ts:78
例外処理の漏れ

```typescript
// 問題のコード
const result = await paymentGateway.charge(amount);
```

**問題**: API呼び出しの失敗時のハンドリングがありません
**修正案**:
```typescript
try {
  const result = await paymentGateway.charge(amount);
} catch (error) {
  logger.error('Payment failed', { error, amount });
  throw new PaymentError('決済処理に失敗しました');
}
```

---

🔵 Info (2件)

### src/utils/format.ts:12
命名の改善提案

`x` → `inputValue` など、より説明的な名前を推奨

---

✅ 良い点

- 適切なTypeScript型定義
- エラーメッセージが分かりやすい
- テストカバレッジが十分
```

---

## Step 6: 次のアクション提案

```
💡 推奨アクション:

1. 🔴 Critical を先に修正
2. 🟡 Warning を確認・対応
3. `/git:draft-commit` でコミットメッセージ生成
4. `/git:pr-create` でPR作成
```

---

## エラーハンドリング

### 差分がない場合

```
⚠️ レビュー対象の変更がありません

確認事項:
- `git status` で変更ファイルを確認
- `git add <file>` でステージ
- または `/git:review --all` で全変更をレビュー
```

### ファイルが見つからない場合

```
❌ エラー: 指定されたファイルが見つかりません

パス: src/notfound.ts

確認事項:
- ファイルパスが正しいか確認
- 相対パス/絶対パスを試す
```
