# 🐟 Fish Shell Configuration

Fish Shell設定。パフォーマンス最適化、プロンプトカスタマイズ、プラグイン統合。

## ✨ 特徴

- **起動最適化**: Lazy Loading、ネイティブ補完使用
- **Git状態表示**: untracked→ピンク、staged→黄色、ahead→緑+マーク
- **fzf統合**: ファイル・履歴・プロセス・リポジトリ検索
- **ディレクトリ移動**: z（頻度ベース）、ghq（リポジトリ管理）

## 🚀 セットアップ

```bash
# 依存ツール
brew install fish fisher fzf peco ghq starship

# プラグインインストール
fisher update

# デフォルトシェルに設定
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

## ⌨️ キーバインディング

| キー | 機能 |
|------|------|
| `Ctrl+R` | コマンド履歴検索 |
| `Ctrl+T` | ファイル検索 |
| `Alt+F` | ディレクトリ検索 |
| `Ctrl+G` | ghqリポジトリ選択 |
| `Ctrl+S` | SSMインスタンス接続 |


## 🎨 カスタマイズ

```fish
# プロンプトテーマ切り替え
set -g FISH_PROMPT_THEME 'starship'  # または 'bobthefish'
```

## 🔧 プラグイン

- **fzf.fish**: ファジー検索
- **z**: 履歴ベースディレクトリ移動
- **ghq**: リポジトリ管理
- **nvm.fish**: Node.jsバージョン管理
- **bobthefish**: プロンプトテーマ
- **fish-async-prompt**: 非同期プロンプト