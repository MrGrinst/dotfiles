#!/bin/bash

# Make config directory
mkdir -p ~/.config/nvim

# Make undo directory
mkdir -p ~/.vim_undo_files

# Link vim config
ln -s ~/Developer/dotfiles/cl-config/vim/init.vim ~/.config/nvim/init.vim

# Link coc config
ln -s ~/Developer/dotfiles/cl-config/vim/coc-settings.json ~/.config/nvim/coc-settings.json

# Install vim-plug
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install vim plugins
vim +PlugInstall +qall
