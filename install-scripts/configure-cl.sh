#!/bin/bash
set -euo pipefail

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "Generating machine's ssh key..."
  ssh-keygen -t ed25519 -C "kyle@grinsteadfam.com" -P "" -f ~/.ssh/id_ed25519
  echo
fi

# Make Homebrew's zsh the login shell. chsh refuses shells that aren't listed in
# /etc/shells, so whitelist it first.
brew_zsh="$(brew --prefix)/bin/zsh"
if ! grep -qxF "$brew_zsh" /etc/shells; then
  echo "$brew_zsh" | sudo tee -a /etc/shells >/dev/null
fi
[ "$SHELL" = "$brew_zsh" ] || chsh -s "$brew_zsh"

# Setup tmux
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Stow (-R restows, so re-running doesn't conflict on already-linked packages)
rm -f ~/.zshrc
cd "$(dirname "$(readlink -f "$0")")/../config"
stow -R --target "$HOME" \
  Aerospace \
  Karabiner \
  assorted-cli \
  ghostty \
  git \
  jj \
  macos-defaults \
  nvim \
  sesh \
  shells \
  starship \
  tmux

echo "Installing languages via mise... (major.minor pins resolve to the latest patch at install time)"
mise use -g erlang@28
mise use -g elixir@1.20.3-otp-28   # OTP-tagged build must match the erlang major above
mise use -g node@24
mise use -g python@3.14

echo "Installing fnox (secrets manager) via mise..."
mise use -g fnox
echo

# bun is managed on its own (self-updates via `bun upgrade`), not via mise
echo "Installing bun..."
curl -fsSL https://bun.sh/install | bash
echo
