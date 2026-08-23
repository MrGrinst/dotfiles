#!/bin/bash
set -euo pipefail

# Close System Settings so it doesn't overwrite what we're about to change
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

# Apply the declarative defaults.
# Source of truth: config/macos-defaults/, stowed to ~/.config/macos-defaults/
macos-defaults apply "$HOME/.config/macos-defaults/"

###############################################################################
# Settings macos-defaults can't own: they need sudo, live in a system-level    #
# plist, or aren't `defaults` at all. Kept here on purpose.                    #
###############################################################################

# Software Update / auto-update live in a system-level plist; user-domain writes
# are ignored, so these must target /Library/Preferences with sudo.
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency -int 1
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -int 1
# App Store app auto-updates
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true

# Not a `defaults` setting: unhide ~/Library in Finder
chflags nohidden "$HOME/Library"

# Restart Finder to pick up the chflags change above
killall Finder >/dev/null 2>&1 || true
