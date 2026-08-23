#!/bin/bash
set -euo pipefail

# Run from this script's directory so relative paths (Brewfile, sibling scripts) resolve
cd "$(dirname "${BASH_SOURCE[0]}")"

# Close any open System Settings pane so it can't override settings we change later
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

# Ask for the administrator password upfront, then keep the sudo timestamp alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Homebrew's installer also installs the Xcode command line tools when missing.
echo "Installing Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
echo

# Tell homebrew cask where to install applications
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

echo "Installing programs from the Brewfile..."
# brew bundle attempts every entry and reports failures at the end; don't let one
# flaky cask abort the rest of the setup.
brew bundle --file=./Brewfile || echo "Some Brewfile entries failed; continuing."
echo

# Accept the Xcode license once the full Xcode app is present (installed via mas above).
if command -v xcodebuild >/dev/null 2>&1; then
  echo "Accepting the Xcode license..."
  sudo xcodebuild -license accept
  echo
fi

echo "Configuring the command line..."
./configure-cl.sh
echo

echo "Configuring system preferences and system application settings..."
./configure-system-prefs.sh
echo
