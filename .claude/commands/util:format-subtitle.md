---
description: YouTube字幕ファイル（txt形式）を読みやすい英語文章に整形
---

# YouTube字幕整形コマンド

YouTube字幕ファイルのパスを受け取り、断片的な字幕を読みやすい文章に整形します。

**引数**: `$ARGUMENTS` - 字幕ファイルのパス

## 処理概要

1. 字幕ファイルを読み込み、チャンクに分割
2. 各チャンクを順次整形処理（オーバーラップで文脈維持）
3. 結果を結合して出力

## 実行手順

### ステップ1: ファイル情報の確認

Readツールで字幕ファイルの先頭100行を読み取り、形式を確認します：
- ファイルパス: `$ARGUMENTS`
- 期待する形式: タブ区切り（Time / Subtitle / Translation）

Bashツールで総行数を確認：
```bash
wc -l "$ARGUMENTS"
```

### ステップ2: チャンク分割と処理

**分割ルール:**
- 1チャンク: 約150行（約10分相当）
- オーバーラップ: 前のチャンクの最後20行を次のチャンクに含める
- 処理対象: `Subtitle`列（英語）のみ

**各チャンクの処理:**

Readツールで字幕ファイルをチャンクごとに読み込みます：
- チャンク1: offset=1, limit=150（ヘッダー行をスキップ）
- チャンク2: offset=131, limit=150（20行オーバーラップ）
- チャンク3: offset=261, limit=150
- ...以降同様

各チャンクに対して、以下の整形を実行：

**整形プロンプト（各チャンクに適用）:**

```
以下のYouTube字幕データ（英語）を、読みやすい文章に整形してください。

【作業内容】
- 字幕の断片的な文章を、自然で流れのある文章に整える
- 意味のまとまりごとに段落を分ける
- 各段落の冒頭にタイムスタンプ（mm:ss形式）を付ける
- [Music]、[Applause]などの記号はそのまま残す
- "Uh", "um"などの不要な間投詞は適宜削除

【AWSサービス・技術用語の取り扱い】
このコンテンツはAWS re:Inventの基調講演です。以下の点に特に注意してください：

- AWSのサービス名や技術用語は必ず正確に保持する
  例：Amazon S3, Amazon Bedrock, AWS Lambda, Amazon EC2, Graviton, Trainium, Nova, Agent Core, SageMaker など
- 元の字幕で明らかに誤っている箇所は、文脈から正しい用語を推測して修正する
  例："bed rock" → "Bedrock", "agent core" → "Agent Core"
- 製品バージョンや型番も正確に保持する
  例：P5, P6, Trainium 2, Trainium 3, Nova Lite, Nova Pro
- 企業名、人名も正確に保持する
  例：Adobe, Sony, NVIDIA, Intel, AMD, Matt Garman

【タイムスタンプのルール】
- 各段落の最初の行の冒頭に時刻を記載
- 形式：mm:ss（例：01:30、15:45）
- 1時間を超える場合：h:mm:ss（例：1:15:30）
- 段落の区切りは、話題が変わるタイミングまたは30秒〜1分程度の間隔

【直前のパートの最終部分】
{前のチャンクの最後の整形済み2-3段落。最初のチャンクでは省略}

【整形対象の字幕】
{現在のチャンクの字幕データ}
```

**重要: チャンク処理時の注意**
- 最初のチャンク以外は、前のチャンクの最後の整形結果（2-3段落）を「直前のパートの最終部分」として含める
- オーバーラップ部分の重複した内容は、結合時に削除する
- 各チャンクの処理結果を一時的に保持し、最後に結合する

### ステップ3: 結果の結合

すべてのチャンクの処理が完了したら：

1. オーバーラップ部分の重複を削除（タイムスタンプで判断）
2. 全チャンクの結果を順番に結合
3. 最終的な整形済みテキストを作成

### ステップ4: 出力ファイルの作成

Writeツールで出力ファイルを作成します。

**出力ファイル名の形式:**
```
{元のファイル名（拡張子なし）}_formatted_{YYYYMMDD}_{HHMMSS}.md
```

例：`Export-Subtitles-AppForLanguage_formatted_20231215_143052.md`

**出力ファイルのパス:** 字幕ファイルと同じディレクトリ

**ファイル先頭に追加するメタ情報:**
```markdown
# {元のファイル名} - Formatted Transcript

- Source: {字幕ファイルのフルパス}
- Processed: {処理日時}
- Total chunks: {処理したチャンク数}

---

```

### ステップ5: 完了報告

処理完了後、以下を報告：
- 出力ファイルのパス
- 処理したチャンク数
- 総行数

## 出力例

```markdown
# Export-Subtitles-AppForLanguage - Formatted Transcript

- Source: /path/to/Export-Subtitles-AppForLanguage.txt
- Processed: 2023-12-15 14:30:52
- Total chunks: 8

---

00:00
[Music]

02:52
Welcome everyone to the 14th annual re:Invent. It's so awesome to be here. We have over 60,000 people here with us in person and almost 2 million watching online, including a bunch of you that are joining us from Fortnite out there. It's where we're streaming the keynote for the first time.

03:26
AWS has grown to be a $132 billion business, accelerating 20% year-over-year. I want to put this a little bit in perspective. The amount we grew in the last year alone is about $22 billion. That absolute growth over the last 12 months is larger than the annual revenue of more than half of the Fortune 500.

03:49
S3 continues to grow with customers storing more than 500 trillion objects, hundreds of exabytes of data, and every day averaging over 200 million requests a second. For the third year in a row, more than half of the CPU capacity that we've added to the AWS cloud comes from Graviton.

04:12
We have millions of customers using our database services and Amazon Bedrock is now powering AI inference for more than 100,000 companies around the world.
```

## エラー処理

- ファイルが見つからない場合: エラーメッセージを表示して終了
- 形式が異なる場合: 検出した形式を報告し、処理可能か確認
- チャンク処理中にエラーが発生: そこまでの結果を保存して継続

## 注意事項

- 処理には時間がかかる場合があります（2時間の動画で10-15分程度）
- 英語字幕（Subtitle列）のみを処理します
- 日本語翻訳が必要な場合は、出力ファイルに対して別途翻訳をかけてください
