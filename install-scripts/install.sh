#!/bin/bash

# Add execution permission to all script files
find ./** -name *.sh | xargs chmod +x

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Allow software to be installed from anywhere
sudo spctl --master-disable

echo "Accepting Xcode license"
  sudo xcodebuild -license
echo

echo "Installing Xcode command line tools"
  xcode-select --install
echo

echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
echo

# Prepare for running homebrew cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

echo "Installing programs..."
  brew bundle
echo

echo "Configuring the command line..."
  ./configure-cl.sh
echo

echo "Configuring vim..."
  ./configure-vim.sh
echo

echo "Configuring GUI programs..."
  ./configure-gui-programs.sh
echo

echo "Configuring system preferences and system application settings..."
  ./configure-system-prefs.sh
echo

echo "Beginning interactive portion..."
  ./interactive-steps.sh
echo
