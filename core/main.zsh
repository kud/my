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
source $MY/core/utils/helper.zsh
source $MY/core/utils/profile-manager.zsh

echo_task_start "Setting up your environment"

################################################################################
# 🔧 ENVIRONMENT SETUP FUNCTIONS
################################################################################

setup_system_foundation() {
    echo_info "Setting up system foundation"
    $MY/core/apps/pcloud.zsh         # Cloud storage setup
    $MY/core/system/default-folders.zsh # Directory structure
    $MY/core/system/sync-files.zsh     # Synchronized files (fonts, etc.)
    $MY/core/system/dotfiles.zsh       # Personal configurations
}

setup_package_managers() {
    echo_info "Installing package managers and packages"
    $MY/core/packages/brew.zsh          # Homebrew packages (now DRY)
    $MY/core/packages/antidote.zsh      # Shell enhancement
    $MY/core/packages/gem.zsh           # Ruby packages
    $MY/core/packages/pip.zsh           # Python packages
    $MY/core/packages/npm.zsh           # Node.js packages
    $MY/core/packages/mas.zsh           # Mac App Store apps
}

setup_development_tools() {
    echo_info "Setting up development tools"
    $MY/core/cli/neovim.zsh        # Text editor setup
    $MY/core/cli/aicommits.zsh     # Smart commit messages
    $MY/core/cli/abbr.zsh          # Command shortcuts
}

setup_applications() {
    echo_info "Setting up applications"
    $MY/core/apps/sublime-merge.zsh # Git interface
    $MY/core/apps/keepassxc.zsh     # Password manager
}

setup_system_components() {
    echo_info "Setting up system components"
    $MY/core/system/submodules.zsh    # Additional components
}

setup_profile_specific_configurations() {
    echo_info "Applying profile-specific configurations"
    apply_profile_configurations
}

################################################################################
# 🚀 MAIN EXECUTION
################################################################################

main() {
    # Validate profile before starting
    detect_and_validate_profile

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

echo_space
echo_task_done "Environment setup completed successfully"
echo_success "All essential components are now ready!"
