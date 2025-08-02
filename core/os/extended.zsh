#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   ⚙️ MACOS ADVANCED SYSTEM CONFIGURATION                                     #
#   ------------------------------------                                       #
#   Applies advanced macOS system preferences and tweaks for optimal          #
#   development experience. Modifies system behaviors and UI preferences.     #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Applying advanced macOS system configurations"
echo_space

# Ask for the administrator password upfront
echo_info "Requesting administrator privileges for system modifications"
sudo -v

echo_space
echo_success "Administrator access granted"

################################################################################
# 🔧 GENERAL SYSTEM PREFERENCES                                                #
################################################################################

echo_info "Configuring general system preferences"

# Disable system sounds
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

# Require password immediately after sleep or screen saver begins
defaults -currentHost write com.apple.screensaver idleTime -int 0

# Set language and text formats
defaults write NSGlobalDomain AppleICUNumberSymbols -dict 0 '.' 1 '' 10 '.' 17 ''

# Disable automatic boot when opening the lid
sudo nvram AutoBoot=%00
# To re-enable: sudo nvram AutoBoot=%03

# Disable "Drag windows to screen edges to tile"
defaults write -g EnableTilingByEdgeDrag -bool false

# Enable "Drag windows to menu bar to fill screen"
defaults write -g EnableTopTilingByEdgeDrag -bool true

# Enable "Hold ⌃ key while dragging windows to tile"
defaults write -g EnableTilingOptionAccelerator -bool true

# Disable "Tiled windows have margins"
defaults write -g EnableTiledWindowMargins -bool false

###############################################################################
# Dock                                                                        #
###############################################################################

# Set Dock orientation to bottom
defaults write com.apple.dock orientation -string "bottom"

# Enable App Expose gesture
defaults write com.apple.dock showAppExposeGestureEnabled -int 1

# Disable Desktop gesture
defaults write com.apple.dock showDesktopGestureEnabled -int 0

# Disable Launchpad gesture
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

###############################################################################
# Screen                                                                      #
###############################################################################

# Include date in screenshot filenames
defaults write com.apple.screencapture "include-date" -int 1

# Rename screenshot prefix
defaults write com.apple.screencapture name -string "macos"

###############################################################################
# Finder                                                                      #
###############################################################################

# Hide tags in Finder
defaults write com.apple.finder ShowRecentTags -bool false

# Hide icons on Desktop
defaults write com.apple.finder CreateDesktop -bool false

# Set Finder default view to column view
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

###############################################################################
# Menu Bar & Control Centre                                                   #
###############################################################################

# Example: Enable/disable Control Centre items (uncomment to customise)
# defaults write com.apple.controlcenter "NSStatusItem Visible AirDrop" -int 0
# defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -int 1
# defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -int 1
# defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -int 1
# defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -int 1

###############################################################################
# MiddleClick                                                                 #
###############################################################################

# Configure MiddleClick to use 4 fingers instead of 3
defaults write com.rouge41.middleClick fingers -int 4

###############################################################################
# Miscellaneous Tweaks                                                        #
###############################################################################

# Disable third-party sponsors in JRE Installer
defaults write ~/Library/Application\ Support/JREInstaller/ThirdParty SPONSORS -string "0"

# Disable "recent items" in the Apple menu
defaults write NSGlobalDomain NSRecentDocumentsLimit -int 0

################################################################################
# 🔄 SYSTEM RESTART NOTIFICATION
################################################################################

echo_space
echo_task_done "Advanced macOS configuration completed"
echo_space
echo_success "System preferences have been optimized for development! 🖥️"
echo_warn "Some changes may require a restart to take full effect"
echo_info "Consider running: sudo shutdown -r now (to restart)"
