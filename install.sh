#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d)"

backup_and_copy() {
    local src="$1"
    local dest="$2"

    if [ -f "$dest" ]; then
        local backup_path="$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
        mkdir -p "$backup_path"
        cp "$dest" "$backup_path/"
        echo "  backed up: $dest -> $backup_path/"
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  installed: $dest"
}

echo "=== dotfiles installer ==="
echo "source: $DOTFILES_DIR"
echo "backup: $BACKUP_DIR"
echo ""

# fish config
echo "[fish]"
backup_and_copy "$DOTFILES_DIR/.config/fish/config.fish" "$HOME/.config/fish/config.fish"

for func in "$DOTFILES_DIR"/.config/fish/functions/*.fish; do
    [ -f "$func" ] || continue
    backup_and_copy "$func" "$HOME/.config/fish/functions/$(basename "$func")"
done

backup_and_copy "$DOTFILES_DIR/.config/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"

# fisher + plugins
echo "[fisher]"
if [ ! -f "$HOME/.config/fish/functions/fisher.fish" ]; then
    echo "  installing fisher..."
    fish -c 'curl -sL https://git.io/fisher | source && fisher update' 2>/dev/null
    echo "  fisher installed with plugins"
else
    echo "  updating plugins..."
    fish -c 'fisher update' 2>/dev/null
    echo "  plugins updated"
fi

# bin
echo "[bin]"
for script in "$DOTFILES_DIR"/bin/*; do
    [ -f "$script" ] || continue
    backup_and_copy "$script" "$HOME/bin/$(basename "$script")"
done

# karabiner
echo "[karabiner]"
backup_and_copy "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# Claude Code
echo "[claude]"
backup_and_copy "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
backup_and_copy "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

for cmd in "$DOTFILES_DIR"/.claude/commands/*.md; do
    [ -f "$cmd" ] || continue
    backup_and_copy "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
done

echo ""
echo "done."
