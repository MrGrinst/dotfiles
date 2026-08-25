#!/bin/bash
# Homebrew install + Brewfile, run early by mise's pre-packages hook so brew's
# zsh and CLI tools exist before the login-shell and tool-install steps.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Quit System Settings up front — an open pane can overwrite the macOS defaults a
# later bootstrap step writes when it's closed. This is the first step to run, so
# it covers the whole `mise bootstrap`.
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

# Keep the sudo timestamp warm for Rosetta / any cask that needs it.
sudo -v || true
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# x86 apps under Apple Silicon; harmless if already present or not needed.
softwareupdate --install-rosetta --agree-to-license >/dev/null 2>&1 || true

# The Homebrew installer also pulls in the Xcode command line tools when missing.
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

echo "Installing programs from the Brewfile..."
# brew bundle tries every entry and reports failures at the end; don't let one
# flaky cask abort the rest of the setup.
brew bundle --file=./Brewfile || echo "Some Brewfile entries failed; continuing."

# Whitelist Homebrew's zsh so the later login-shell step can select it — chsh
# refuses shells that aren't listed in /etc/shells. Done here (right after brew
# installs it) so it's in place before mise's [bootstrap.user] login_shell runs.
brew_zsh="$(brew --prefix)/bin/zsh"
if [[ -x "$brew_zsh" ]] && ! grep -qxF "$brew_zsh" /etc/shells; then
  echo "$brew_zsh" | sudo tee -a /etc/shells >/dev/null
fi

# Guard the Claude files [dotfiles] is about to symlink: bail if either already
# exists as real (non-symlink) content, so we never clobber a machine's existing
# Claude config. Runs in the pre-packages hook, before the dotfiles step links them;
# already-linked symlinks are fine and get relinked.
for f in ~/.claude/CLAUDE.md ~/.claude/settings.json; do
  if [[ -e "$f" && ! -L "$f" ]]; then
    echo "Error: $f exists and isn't a symlink; move it aside before bootstrapping." >&2
    exit 1
  fi
done
