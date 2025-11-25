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
# Window Management (macOS 13+)                                               #
###############################################################################

# Disable Stage Manager by default
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Group windows by application in app switcher
defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 1

# Hide Desktop widgets in standard mode
defaults write com.apple.WindowManager StandardHideWidgets -int 0

###############################################################################
# Modern macOS 15+ Features                                                   #
###############################################################################

# Auto-hide menu bar in fullscreen
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -int 0

# Disable inline predictive text (macOS 14+)
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false

# Function key behavior (0 = F1-F12 as standard, 1 = special features)
defaults write NSGlobalDomain com.apple.keyboard.fnState -int 0

###############################################################################
# Enhanced Trackpad Gestures                                                  #
###############################################################################

# Enable three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Four-finger gestures for Mission Control
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2

###############################################################################
# Control Center & Menu Bar Items                                             #
###############################################################################

# Show/hide specific Control Center items
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

###############################################################################
# Enhanced Dock Settings                                                      #
###############################################################################

# Dock magnification
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock largesize -int 64

###############################################################################
# Enhanced Finder Settings                                                    #
###############################################################################

# Show folder item count in Icon view
defaults write com.apple.finder ShowItemInfo -bool true

# Set default Finder folder arrangement
defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"

###############################################################################
# Screenshots Enhancements                                                    #
###############################################################################

# Show thumbnail after screenshot
defaults write com.apple.screencapture show-thumbnail -bool true

###############################################################################
# Privacy & Security                                                          #
###############################################################################

# Disable Siri suggestions in Spotlight
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true

# Disable personalized ads
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

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
