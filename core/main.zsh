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

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh

################################################################################
# 🔧 ENVIRONMENT SETUP FUNCTIONS
################################################################################

setup_system_foundation() {
    ui_spacer
    ui_primary "🏗️ Setting up system foundation"
    
    ui_info_simple "Configuring cloud storage..."
    $MY/core/apps/pcloud.zsh
    
    ui_info_simple "Creating directory structure..."
    $MY/core/system/default-folders.zsh
    
    ui_info_simple "Syncing files..."
    $MY/core/system/sync-files.zsh
    
    ui_info_simple "Installing dotfiles..."
    $MY/core/system/dotfiles.zsh
    
    ui_success_simple "System foundation ready"
}

setup_package_managers() {
    ui_spacer
    ui_primary "📦 Installing packages"
    
    ui_info_simple "Updating Homebrew packages..."
    if ! $MY/core/packages/brew.zsh; then
        exit 1
    fi
    
    ui_info_simple "Configuring shell enhancements..."
    $MY/core/packages/antidote.zsh
    
    ui_info_simple "Installing Ruby gems..."
    $MY/core/packages/gem.zsh
    
    ui_info_simple "Installing Python packages..."
    $MY/core/packages/pip.zsh
    
    ui_info_simple "Installing Node.js packages..."
    $MY/core/packages/npm.zsh
    
    ui_info_simple "Installing Mac App Store apps..."
    $MY/core/packages/mas.zsh
    
    ui_success_simple "All packages installed"
}

setup_development_tools() {
    ui_spacer
    ui_primary "🛠️ Configuring development tools"
    
    ui_info_simple "Setting up AI commits..."
    $MY/core/cli/aicommits.zsh
    
    ui_info_simple "Creating command shortcuts..."
    $MY/core/cli/abbr.zsh
    
    ui_success_simple "Development tools configured"
}

setup_applications() {
    ui_spacer
    ui_primary "💻 Configuring applications"
    
    ui_info_simple "Setting up Sublime Merge..."
    $MY/core/apps/sublime-merge.zsh
    
    ui_info_simple "Configuring KeePassXC..."
    $MY/core/apps/keepassxc.zsh
    
    ui_success_simple "Applications configured"
}

setup_system_components() {
    ui_spacer
    ui_primary "🔌 Installing system components"
    
    ui_info_simple "Updating submodules..."
    $MY/core/system/submodules.zsh
    
    ui_success_simple "System components ready"
}

setup_profile_specific_configurations() {
    # Profile-specific configs are handled automatically by each component
    # when $OS_PROFILE is set - no explicit action needed here
    if [[ -n "$OS_PROFILE" ]]; then
        ui_spacer
        ui_info_simple "Profile: $OS_PROFILE applied"
    fi
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
    
    ui_spacer
    ui_success_msg "Environment setup complete! ✨"
}

# Execute main setup
main