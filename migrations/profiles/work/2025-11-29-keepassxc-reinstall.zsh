#!/usr/bin/env zsh

################################################################################
# Migration: KeePassXC Reinstall (Work Profile)
# Date: 2025-11-29
# Description: Cleanup and reinstall KeePassXC cask to fix issues
################################################################################

source $MY/core/utils/ui-kit.zsh

ui_info_simple "Cleaning up Homebrew cache"
brew cleanup

ui_info_simple "Reinstalling KeePassXC"
brew reinstall --cask keepassxc

ui_success_simple "KeePassXC reinstalled successfully"
