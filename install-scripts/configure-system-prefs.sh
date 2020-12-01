#!/bin/bash

#########
# Mouse #
#########

# Enable tap to click
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.mouse.tapBehavior -int 1

# Fix scrolling
defaults write -g com.apple.swipescrolldirection -bool false

# Three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true


############
# Keyboard #
############

# Disable smart quotes and dashes
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# Enable key repeat, set rate, and delay
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 1.15
defaults write -g InitialKeyRepeat -int 15

# Enable Tab in modal dialogs
defaults write -g AppleKeyboardUIMode -int 3

# Update typing stuff
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticTextCompletionEnabled -bool false


###############
# Screenshots #
###############

# Change screenshot save location
defaults write com.apple.screencapture location ~/Downloads

# Make screenshots use jpg format
defaults write com.apple.screencapture type jpg

# Change default screenshot name
defaults write com.apple.screencapture name "screenshot"

# Disable shadows in screenshots
defaults write com.apple.screencapture disable-shadow -bool true


######################
# Random Preferences #
######################

# Show percentage in battery status
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "NO"

# Don't automatically adjust display brightness
defaults write com.apple.BezelServices dAuto -boolean false

# Reduce transparency across the system (dock, menu bars, etc.)
sudo defaults write com.apple.universalaccess reduceTransparency -bool true

# Disable Resume system-wide
defaults write -g NSQuitAlwaysKeepsWindows -bool false

# Require password after a minute after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 60

# Disable annoying sound effects
defaults write -g com.apple.sound.beep.feedback -integer 0

# Speed up mission control animation
defaults write com.apple.dock expose-animation-duration -float 0.12

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

# Disable "reopen windows when logging back in"
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false


##########
# Finder #
##########

# New window points to home
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Don't show hard drives on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Don't show recent tags
defaults write com.apple.finder ShowRecentTags -bool false

# Show the ~/Library folder in Finder
chflags nohidden ~/Library

# Show hidden files by default
defaults write com.apple.Finder AppleShowAllFiles -bool false

# Use list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show all file extensions
defaults write -g AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Expand save dialog by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write -g PMPrintingExpandedStateForPrint -bool true

# Save to disk by default
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

# Don't write .DS_Store files on USB drives
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a Finder window when mounting a new disk
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true


########
# Dock #
########

# Position
defaults write com.apple.dock orientation -string "right"

# Enable autohide
defaults write com.apple.dock autohide -bool true

# Change autohide appear time
defaults write com.apple.dock autohide-time-modifier -int 0

# Wipe all app icons from the Dock
defaults write com.apple.dock persistent-apps -array

# Only show active apps
defaults write com.apple.dock static-only -bool true

# Show hidden applications as translucent
defaults write com.apple.dock showhidden -bool true

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Disable bouncing in the dock
defaults write com.apple.dock no-bouncing -bool false

# Restart some stuff
killall "Finder" > /dev/null 2>&1
killall "SystemUIServer" > /dev/null 2>&1
killall "Dock" > /dev/null 2>&1
killall "cfprefsd" > /dev/null 2>&1
