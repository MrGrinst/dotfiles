#!/bin/bash

# Link the rcs and profiles
ln -sf ~/Developer/dotfiles/cl-config/zshrc ~/.zshrc
ln -sf ~/Developer/dotfiles/cl-config/zshenv ~/.zshenv
ln -sf ~/Developer/dotfiles/cl-config/profile ~/.profile
ln -sf ~/Developer/dotfiles/cl-config/aliases ~/.aliases
ln -sf ~/Developer/dotfiles/cl-config/bashrc ~/.bashrc
ln -sf ~/Developer/dotfiles/cl-config/shrc ~/.shrc
ln -sf ~/Developer/dotfiles/cl-config/ripgreprc ~/.ripgreprc

if [[ ! -f ~/.ssh/id_dsa ]]; then
  echo "Generating machine's ssh key..."
    ssh-keygen -t ed25519 -C "kyleag@hey.com" -P "" -f ~/.ssh/id_dsa
  echo
fi

# Change shell to zsh
chsh -s /opt/homebrew/bin/zsh

echo "Installing oh-my-zsh..."
  # This env function is a hacky way to prevent a new shell from spawning when oh-my-zsh is done installing
  env() {
    if ! [[ \$1 = zsh ]]; then /usr/bin/env \$@; fi;
  }
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo

echo "Installing elixir, erlang, node, python, and ruby..."
  asdf plugin add elixir
  asdf plugin add erlang
  asdf plugin add nodejs
  asdf plugin add python
  asdf plugin add ruby
  asdf install elixir 1.13.2
  asdf install erlang 24.2.1
  asdf install nodejs 16.13.1
  asdf install python 3.10.0
  asdf install ruby 3.1.0
  asdf global elixir 1.13.2
  asdf global erlang 24.2.1
  asdf global nodejs 16.13.1
  asdf global python 3.10.0
  asdf global ruby 3.1.0
echo

echo "Installing tmuxifier..."
  git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
echo

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
mkdir -p "$(bat --config-dir)/themes/base16-improved"
ln -sf ~/Developer/dotfiles/cl-config/bat/themes/base16-improved "$(bat --config-dir)/themes/base16-improved"
bat cache --build
