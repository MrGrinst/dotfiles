#!/bin/bash

#########
# Mouse #
#########

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Fix scrolling
defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false

# Three finger swipe for navigation
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1


############
# Keyboard #
############

# Disable smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Enable key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
#
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use function keys by default
defaults write -g com.apple.keyboard.fnState -bool true

# Set a shorter delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 12

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Stop the play button from starting iTunes when no other music app is open
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist

# Prevent iTunes from popping up automatically when a phone is plugged in
sudo rm -r /Applications/iTunes.app/Contents/MacOS/iTunesHelper.app


######################
# Random Preferences #
######################

# Change screenshot save location
defaults write com.apple.screencapture location ~/Downloads

# Make screenshots use jpg format
defaults write com.apple.screencapture type jpg

# Disable the 'Are you sure you want to open this application?' dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Show percentage in battery status
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "NO"

# Don't automatically adjust display brightness
defaults write com.apple.BezelServices dAuto -boolean false

# Use dark mode
defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark

# Reduce transparency across the system (dock, menu bars, etc.)
defaults write com.apple.universalaccess reduceTransparency -bool true

# Require password after a minute after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 60

# Disable sound effect when changing volume
defaults write -g com.apple.sound.beep.feedback -integer 0<Paste>

# Menu bar: hide the User icon
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
   defaults write "${domain}" dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/User.menu"
done

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true


############
# Messages #
############

# Disable automatic emoji substitution (i.e. use plain text smileys)
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Disable smart quotes as it’s annoying for messages that contain code
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false


##########
# Finder #
##########

# New window points to home
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Don't show hard drives on desktop
default write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Don't show recent tags
default write com.apple.finder ShowRecentTags -bool false

# Show the ~/Library folder in Finder
chflags nohidden ~/Library

# Show hidden files by default
defaults write com.apple.Finder AppleShowAllFiles -bool false

# Use list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Expand save dialog by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Automatically open a Finder window when mounting a new disk
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Add all of the sidebar favorites in the correct order
curl -fLo "mysides.pkg" https://github.com/mosen/mysides/releases/download/v1.0.1/mysides-1.0.1.pkg
sudo installer -pkg mysides.pkg -target /
rm mysides.pkg
mysides add Applications file:///Applications
mysides add Home file:///$HOME
mysides add Documents file:///$HOME/Documents
mysides add Developer file:///$HOME/Developer
mysides add Downloads file:///$HOME/Downloads

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"


########
# Dock #
########

# Position
defaults write com.apple.dock orientation -string "right"

# Enable autohide
defaults write com.apple.dock autohide -bool true

# Change autohide appear time
defaults write com.apple.dock autohide-time-modifier -int 0

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use
# the Dock to launch apps.
defaults write com.apple.dock persistent-apps -array

# Only show active apps
defaults write com.apple.dock static-only -bool true

# Show hidden applications as translucent
defaults write com.apple.dock showhidden -bool true

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Restart some stuff

killall "Finder" > /dev/null 2>&1
killall "SystemUIServer" > /dev/null 2>&1
killall "Dock" > /dev/null 2>&1
