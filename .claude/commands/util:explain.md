---
description: ファイル/ディレクトリ/コードの解説
allowed-tools: ["Read(**)", "Glob(**)", "Grep(**)", "Bash(ls:*)", "Bash(tree:*)"]
---

# 解説

ファイル、ディレクトリ、コードの内容を解説します。

## 引数

`$ARGUMENTS`

| 入力 | 動作 |
|------|------|
| `<パス>` | 指定パスを解説（必須） |
| `--level brief` | 概要のみ（デフォルト） |
| `--level detailed` | 詳細な解説 |
| `--ja` | 日本語で解説（デフォルト） |
| `--en` | 英語で解説 |

例: `/util:explain src/services/ --level detailed`

---

## Step 1: 対象の種類を判定

### ファイルの場合

Readツールでファイル内容を読み込み

### ディレクトリの場合

```bash
ls -la <path>
tree -L 2 <path>  # treeがある場合
```

ディレクトリ構成を把握

---

## Step 2: 対象に応じた解説

### 2-1: ソースコードファイル

**解説項目:**
- ファイルの目的・役割
- 主要なクラス/関数の概要
- 依存関係（import/require）
- 外部から呼び出される箇所（export）

**出力例（brief）:**
```
📄 src/services/auth.ts

## 概要
認証サービスの実装。ログイン、ログアウト、トークン管理を担当。

## 主要な機能
- `login(email, password)` - ユーザー認証
- `logout()` - セッション終了
- `refreshToken()` - トークン更新
- `validateToken(token)` - トークン検証

## 依存関係
- `./user-repository` - ユーザーデータアクセス
- `jsonwebtoken` - JWT生成・検証
- `bcrypt` - パスワードハッシュ
```

**出力例（detailed）:**

briefの内容に加えて:
- 各関数の詳細な動作説明
- エラーハンドリングの方針
- セキュリティ考慮事項
- 使用例

### 2-2: 設定ファイル

**対象:** `.json`, `.yaml`, `.toml`, `.env.*`, `Dockerfile`, etc.

**解説項目:**
- 設定の目的
- 主要な設定項目と意味
- デフォルト値と変更時の影響
- 関連する環境変数

**出力例:**
```
📄 tsconfig.json

## 概要
TypeScriptコンパイラの設定ファイル

## 主要設定
| 項目 | 値 | 意味 |
|------|-----|------|
| target | ES2022 | 出力するJSのバージョン |
| strict | true | 厳格な型チェック有効 |
| moduleResolution | bundler | バンドラー向け解決 |

## 注意点
- `paths` でエイリアスを定義（@/ → src/）
- `include` でコンパイル対象を限定
```

### 2-3: ディレクトリ

**解説項目:**
- ディレクトリの役割
- 主要なファイル/サブディレクトリの概要
- ファイル間の関係性
- 命名規則やパターン

**出力例:**
```
📁 src/services/

## 概要
ビジネスロジックを実装するサービス層

## 構成
```
services/
├── auth.ts        # 認証サービス
├── user.ts        # ユーザー管理
├── payment.ts     # 決済処理
├── notification/  # 通知サービス群
│   ├── email.ts
│   ├── push.ts
│   └── index.ts
└── index.ts       # 公開エクスポート
```

## パターン
- 各サービスはシングルトンパターン
- `index.ts` で公開APIを集約
- notification/ のようにサブディレクトリで関連機能をグループ化

## 依存関係
- repositories/ 層に依存
- controllers/ から呼び出される
```

### 2-4: プロジェクトルート

パスが `.` やプロジェクトルートの場合:

**解説項目:**
- プロジェクトの概要
- 技術スタック
- ディレクトリ構成の全体像
- 開発・ビルド・デプロイの流れ

---

## Step 3: 関連ファイルの提示

解説対象に関連する重要ファイルを提示:

```
📎 関連ファイル
- src/repositories/user-repository.ts - データアクセス層
- src/controllers/auth-controller.ts - このサービスを使用
- src/types/auth.ts - 型定義
- tests/services/auth.test.ts - テストコード
```

---

## Step 4: 理解を深めるためのヒント

```
💡 さらに詳しく知るには

- `/util:explain src/services/auth.ts --level detailed` で詳細解説
- `login` 関数の呼び出し元を探す: Grep で "auth.login" を検索
- 認証フローの全体像: src/middleware/auth.ts も参照
```

---

## エラーハンドリング

### パスが指定されていない場合

```
⚠️ 解説対象のパスを指定してください

使用例:
/util:explain src/services/auth.ts
/util:explain src/components/
/util:explain package.json
```

### パスが存在しない場合

```
❌ エラー: 指定されたパスが見つかりません

パス: src/notfound/

確認事項:
- パスが正しいか確認
- 相対パス/絶対パスを試す
- `ls` で存在確認
```

### バイナリファイルの場合

```
⚠️ バイナリファイルは解説できません

ファイル: assets/logo.png

代わりに:
- 画像ファイル: ファイル名から用途を推測
- 実行ファイル: 関連するソースコードを解説
```
