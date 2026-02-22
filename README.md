# dotfiles

macOS 向けの個人設定ファイル。fish shell + Claude Code を中心にした構成。

## セットアップ

[osx-ansible](https://github.com/snakagawax/osx-ansible) でパッケージとOS設定を済ませた後に実行。

```bash
cd ~/ghq/github.com/snakagawax/dotfiles
bash install.sh
```

install.sh は既存ファイルを `~/.dotfiles-backup/YYYYMMDD/` にバックアップしてから上書きコピーする。
fisher が未インストールの場合は自動でインストールし、fish_plugins に記載されたプラグインもセットアップする。

### fish をデフォルトシェルに設定

```bash
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
```

## 構成

```
.claude/              Claude Code の設定とカスタムコマンド
.config/fish/         fish shell の設定・プラグイン定義・カスタム関数
.config/karabiner/    Karabiner-Elements のキーマップ
.config/starship.toml Starship プロンプト設定
.config/Code/User/    VS Code の設定
bin/                  スクリプト（assume-role.fish 等）
```

## fish プラグイン（fisher 管理）

- [edc/bass](https://github.com/edc/bass) - bash スクリプトを fish から実行
- [decors/fish-ghq](https://github.com/decors/fish-ghq) - ghq リポジトリ選択（Ctrl+G）
- [PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish) - fzf 統合（Ctrl+R で履歴検索等）
- [jethrokuan/z](https://github.com/jethrokuan/z) - ディレクトリジャンプ

## 前提

- macOS (Apple Silicon)
- [osx-ansible](https://github.com/snakagawax/osx-ansible) で fish, fzf, ghq, starship, peco 等がインストール済み
