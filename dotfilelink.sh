#!bin/bash

DOTFILES_DIR=${HOME}/.ghq/github.com/snakagawax/dotfiles
 
ln -fs ${DOTFILES_DIR}/.bashrc ${HOME}
ln -fs ${DOTFILES_DIR}/.bash_profile ${HOME}