#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎯 ENVIRONMENT ORCHESTRATOR                                                 #
#   --------------------------                                                 #
#   Master orchestrator that executes all core system setup scripts in        #
#   the correct order for a complete development environment setup.           #
#   Now with DRY principles and profile-aware configuration.                  #
#                                                                              #
################################################################################

setopt EXTENDED_GLOB

################################################################################
# 🔧 ENVIRONMENT SETUP FUNCTIONS
################################################################################

setup_system_foundation() {
    $MY/core/apps/pcloud.zsh         # Cloud storage setup
    $MY/core/system/default-folders.zsh # Directory structure
    $MY/core/system/sync-files.zsh     # Synchronized files (fonts, etc.)
    $MY/core/system/dotfiles.zsh       # Personal configurations
}

setup_package_managers() {
    $MY/core/packages/brew.zsh          # Homebrew packages (now DRY)
    $MY/core/packages/antidote.zsh      # Shell enhancement
    $MY/core/packages/gem.zsh           # Ruby packages
    $MY/core/packages/pip.zsh           # Python packages
    $MY/core/packages/npm.zsh           # Node.js packages
    $MY/core/packages/mas.zsh           # Mac App Store apps
}

setup_development_tools() {
    $MY/core/cli/aicommits.zsh     # Smart commit messages
    $MY/core/cli/abbr.zsh          # Command shortcuts
}

setup_applications() {
    $MY/core/apps/sublime-merge.zsh # Git interface
    $MY/core/apps/keepassxc.zsh     # Password manager
}

setup_system_components() {
    $MY/core/system/submodules.zsh    # Additional components
}

setup_profile_specific_configurations() {
    # Profile-specific configs are handled automatically by each component
    # when $OS_PROFILE is set - no explicit action needed here
}

################################################################################
# 🚀 MAIN EXECUTION
################################################################################

main() {
    # Execute setup in logical order
    setup_system_foundation
    setup_package_managers
    setup_development_tools
    setup_applications
    setup_system_components
    setup_profile_specific_configurations
}

# Execute main setup
main

