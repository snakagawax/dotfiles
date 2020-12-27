#!bin/bash

DOTFILES_DIR=${HOME}/ghq/github.com/snakagawax/dotfiles
 
ln -fs ${DOTFILES_DIR}/.bashrc ${HOME}
ln -fs ${DOTFILES_DIR}/.bash_profile ${HOME}
ln -fs ${DOTFILES_DIR}/.gitignore_global ${HOME}
ln -fs ${DOTFILES_DIR}/.inputrc ${HOME}
ln -fs ${DOTFILES_DIR}/.config/fish/config.fish ${HOME}/.config/fish/
ln -fs ${DOTFILES_DIR}/.config/karabiner/karabiner.json ${HOME}/.config/karabiner/