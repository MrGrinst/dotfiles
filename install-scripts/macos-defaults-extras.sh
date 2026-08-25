#!/bin/bash
# macOS settings mise's declarative [bootstrap.macos.defaults] can't express, plus
# the app restarts that pick up the defaults it does write. Run by the
# post-defaults hook, right after `mise bootstrap macos defaults apply`.
set -euo pipefail

# Re-acquire root: brew's sudo keepalive is scoped to that step and has long since
# expired by the time this hook runs, so refresh the timestamp and keep it warm for
# the system-plist writes below.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Dock: wipe pinned apps. An empty array isn't a scalar, so it can't live in
# [bootstrap.macos.defaults] (which only writes -bool/-int/-float/-string).
defaults write com.apple.dock persistent-apps -array

# Battery percentage moved to Control Center (Big Sur+) and is a per-host
# (ByHost) preference, which the generic defaults table can't target.
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# Settings that need sudo / live in a system-level plist — user-domain writes are
# ignored, so these target /Library/Preferences with sudo.
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency -int 1
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -int 1
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true

# Not a `defaults` setting: unhide ~/Library in Finder.
chflags nohidden "$HOME/Library"

# Restart the apps whose defaults changed so they pick them up now.
for app in Dock Finder SystemUIServer ControlCenter WindowManager; do
  killall "$app" >/dev/null 2>&1 || true
done
