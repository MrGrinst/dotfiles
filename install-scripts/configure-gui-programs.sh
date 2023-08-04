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
