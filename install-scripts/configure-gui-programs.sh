#!/bin/bash

##########
# iTerm2 #
##########

echo "Configuring iTerm2..."
  # Make iTerm2 load from external config file
  defaults write com.googlecode.iterm2 "PrefsCustomFolder" -string ~/Developer/dotfiles/gui-config/iTerm2
  defaults write com.googlecode.iterm2 "LoadPrefsFromCustomFolder" -bool true
echo


##########
# Alfred #
##########

echo "Configuring Alfred..."
  defaults write com.runningwithcrayons.Alfred-Preferences-3 "syncfolder" -string "$HOME/Developer/dotfiles/gui-config/Alfred"
echo


#############
# Spectacle #
#############

echo "Configuring Spectacle..."
  mkdir -p  "$HOME/Library/Application Support/Spectacle"
  ln -s ~/Developer/dotfiles/gui-config/Spectacle/Shortcuts.json "$HOME/Library/Application Support/Spectacle/Shortcuts.json"
echo
