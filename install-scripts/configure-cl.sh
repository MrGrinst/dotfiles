#!/bin/bash

# Link the rcs and profiles
ln -sf ~/Developer/dotfiles/cl-config/zshrc ~/.zshrc
ln -sf ~/Developer/dotfiles/cl-config/zshenv ~/.zshenv
ln -sf ~/Developer/dotfiles/cl-config/profile ~/.profile
ln -sf ~/Developer/dotfiles/cl-config/aliases ~/.aliases
ln -sf ~/Developer/dotfiles/cl-config/bashrc ~/.bashrc
ln -sf ~/Developer/dotfiles/cl-config/shrc ~/.shrc
ln -sf ~/Developer/dotfiles/cl-config/ripgreprc ~/.ripgreprc

if [[ ! -f ~/.ssh/id_rsa ]]; then
  echo "Generating machine's ssh key..."
    ssh-keygen -t rsa -b 4096 -C "kyleag@hey.com" -P "" -f ~/.ssh/id_rsa
  echo
fi

# Change shell to zsh
chsh -s /usr/local/bin/zsh

echo "Installing oh-my-zsh..."
  # This env function is a hacky way to prevent a new shell from spawning when oh-my-zsh is done installing
  env() {
    if ! [[ \$1 = zsh ]]; then /usr/bin/env \$@; fi;
  }
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  ln -s ~/Developer/dotfiles/cl-config/zsh-plugins/actuator ~/.oh-my-zsh/custom/plugins
echo

echo "Installing and setting node version..."
  nodenv install 15.3.0
  nodenv global 15.3.0
echo

echo "Installing and setting python version..."
  pyenv install 3.9.0
  pyenv global 3.9.0
echo

echo "Installing and setting ruby version..."
  rbenv install 2.7.2
  rbenv global 2.7.2
echo

echo "Installing tmuxifier..."
  git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
echo

echo "Installing gems..."
  ./install-gems.sh
echo

echo "Installing npm packages..."
  ./install-npm-packages.sh
echo

# Install italics support for tmux
tic ./italics-support/tmux-256color-italic.terminfo
tic ./italics-support/xterm-256color-italic.terminfo

# Install fzf shell extensions
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# Link the git files
ln -s ~/Developer/dotfiles/cl-config/git/config ~/.gitconfig
ln -s ~/Developer/dotfiles/cl-config/git/gitignore ~/.gitignore_global

# Link the tmux.conf file
ln -s ~/Developer/dotfiles/cl-config/tmux.conf ~/.tmux.conf

# Link the zsh overrides file
ln -s ~/Developer/dotfiles/cl-config/zsh-overrides.zsh ~/.oh-my-zsh/custom/zsh-overrides.zsh

# Link the irbrc file
ln -s ~/Developer/dotfiles/cl-config/irbrc ~/.irbrc

# Configure bat
mkdir -p ~/.config
ln -s ~/Developer/dotfiles/cl-config/bat ~/.config/bat

# Install sshpass (allows ssh commands to be run with the password inline; useful for doing server setup)
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
