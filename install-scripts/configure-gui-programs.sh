#!/bin/bash

##########
# iTerm2 #
##########

echo "Configuring iTerm2..."
  # Make iTerm2 load from external config file
  defaults write com.googlecode.iterm2 "PrefsCustomFolder" -string "~/Developer/dotfiles/gui-config/iTerm2"
  defaults write com.googlecode.iterm2 "LoadPrefsFromCustomFolder" -bool true

  # Install italics support for iTerm
  tic ./italics-support/xterm-256color-italic.terminfo
echo


##########
# Chrome #
##########

echo "Configuring Chrome..."
  # Use the system-native print preview dialog
  defaults write com.google.Chrome DisablePrintPreview -bool true
  defaults write com.google.Chrome.canary DisablePrintPreview -bool true

  # Expand the print dialog by default
  defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
  defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true
echo


###############
# Hammerspoon #
###############

echo "Configuring Hammerspoon..."
  # Link init.lua file
  mkdir -p ~/.hammerspoon
  ln -s ~/Developer/dotfiles/gui-config/Hammerspoon/init.lua ~/.hammerspoon/init.lua
echo


##########
# Alfred #
##########

echo "Configuring Alfred..."
  defaults write com.runningwithcrayons.Alfred-Preferences-3 "syncfolder" -string "~/Developer/dotfiles/gui-config/Alfred"
echo


#############
# Spectacle #
#############

echo "Configuring Spectacle..."
  mkdir -p  "~/Library/Application Support/Spectacle"
  ln -s ~/Developer/dotfiles/gui-config/Spectacle/Shortcuts.json "~/Library/Application Support/Spectacle/Shortcuts.json"
echo


###########################
# Uninstall Google Update #
###########################

echo "Uninstalling Google Update"
  ~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall --nuke
echo
