#!/bin/bash

echo "Copied public key to clipboard"
pbcopy < ~/.ssh/id_rsa.pub
echo -n "Hit ENTER to navigate to Github's key settings page"
read
open "https://github.com/settings/keys"
echo -n "Hit ENTER to navigate to Bitbucket's key settings page"
read
open "https://bitbucket.org/account/user/MrGrinst/ssh-keys/"
echo -n "Hit ENTER when done adding SSH keys"

echo "Opening Dashlane..."
osascript -e 'tell application "Dashlane" to activate'
echo -n "Hit ENTER when done logging into Dashlane"

