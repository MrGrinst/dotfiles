#!/bin/bash

# Link the rcs and profiles
rm ~/.zshrc
ln -s ~/Developer/dotfiles/cl-config/zshrc ~/.zshrc
rm ~/.profile
ln -s ~/Developer/dotfiles/cl-config/profile ~/.profile
rm ~/.bashrc
ln -s ~/Developer/dotfiles/cl-config/bashrc ~/.bashrc
rm ~/.shrc
ln -s ~/Developer/dotfiles/cl-config/shrc ~/.shrc

echo "Generating machine's ssh key..."
  ssh-keygen -t rsa -b 4096 -C "kyle@kylegrinstead.com" -P "" -f ~/.ssh/id_rsa
echo

# Change shell to zsh
chsh -s /usr/local/bin/zsh

echo "Installing oh-my-zsh..."
  # This env function is a hacky way to prevent a new shell from spawning when oh-my-zsh is done installing
  env() {
    if ! [ \$1 = zsh ]; then /usr/bin/env \$@; fi;
  }
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo

echo "Installing ndenv..."
  git clone https://github.com/riywo/ndenv ~/.ndenv
  git clone https://github.com/riywo/node-build.git $(ndenv root)/plugins/node-build
echo

echo "Installing and setting node version..."
  ndenv install v6.11.4
  ndenv global v6.11.4
echo

echo "Installing and setting python version..."
  pyenv install 3.6.3
  pyenv global 3.6.3
echo

echo "Installing and setting ruby version..."
  rbenv install 2.4.1
  rbenv global 2.4.1
echo

# Install italics support for tmux
tic ./italics-support/tmux-256color-italic.terminfo

# Install fzf shell extensions
/usr/local/opt/fzf/install --key-bindings --completion --update-rc

# Link the git files
ln -s ~/Developer/dotfiles/cl-config/git/config ~/.gitconfig
ln -s ~/Developer/dotfiles/cl-config/git/gitignore ~/.gitignore_global

# Link the tmux.conf file
ln -s ~/Developer/dotfiles/cl-config/tmux.conf ~/.tmux.conf

# Link the zsh overrides file
ln -s ~/Developer/dotfiles/cl-config/zsh-overrides.zsh ~/.oh-my-zsh/custom/zsh-overrides.zsh

# Link the irbrc file
ln -s ~/Developer/dotfiles/cl-config/irbrc ~/.irbrc

# Install sshpass (allows ssh commands to be run with the password inline; useful for doing server setup)
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
