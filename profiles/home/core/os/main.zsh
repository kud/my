#! /usr/bin/env zsh


###############################################################################
# General UI/UX                                                               #
###############################################################################

sudo scutil --set ComputerName "_kud.home"
sudo scutil --set HostName "_kud.home"
sudo scutil --set LocalHostName "kud-home"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "kud-home"
