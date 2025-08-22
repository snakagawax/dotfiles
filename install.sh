#!/bin/bash
# Dotfiles Installation Script
# Fish Shell + Configuration Setup

set -e

DOTFILES_DIR="$HOME/ghq/github.com/snakagawax/dotfiles"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐟 Fish Shell Dotfiles Installation${NC}"
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
    echo "Please clone the repository first:"
    echo "  ghq get https://github.com/snakagawax/dotfiles.git"
    exit 1
fi

# Create necessary directories
echo -e "${GREEN}📁 Creating directories...${NC}"
mkdir -p ~/.config

# Create symbolic links
echo -e "${GREEN}🔗 Creating symbolic links...${NC}"

# Git configuration
if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
    echo "   ✅ .gitconfig"
fi

if [ -f "$DOTFILES_DIR/.gitignore_global" ]; then
    ln -sf "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global
    echo "   ✅ .gitignore_global"
fi

if [ -f "$DOTFILES_DIR/.inputrc" ]; then
    ln -sf "$DOTFILES_DIR/.inputrc" ~/.inputrc
    echo "   ✅ .inputrc"
fi

# Fish configuration
if [ -d "$DOTFILES_DIR/.config/fish" ]; then
    ln -sf "$DOTFILES_DIR/.config/fish" ~/.config/fish
    echo "   ✅ Fish configuration"
fi

# Karabiner configuration
if [ -d "$DOTFILES_DIR/.config/karabiner" ]; then
    ln -sf "$DOTFILES_DIR/.config/karabiner" ~/.config/karabiner
    echo "   ✅ Karabiner configuration"
fi

echo ""
echo -e "${GREEN}🎉 Dotfiles installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Install Fish shell: brew install fish"
echo "2. Install Fisher plugins: fish -c 'fisher update'"
echo "3. Set Fish as default shell: chsh -s /opt/homebrew/bin/fish"
echo ""
echo "Configuration files linked:"
echo "  • ~/.config/fish → $DOTFILES_DIR/.config/fish"
echo "  • ~/.gitconfig → $DOTFILES_DIR/.gitconfig"
echo "  • ~/.gitignore_global → $DOTFILES_DIR/.gitignore_global"