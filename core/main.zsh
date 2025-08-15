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
    
    ui_secondary "## Cloud Storage Setup"
    $MY/core/apps/pcloud.zsh
    
    ui_secondary "## Default Directories"
    $MY/core/system/default-folders.zsh
    
    ui_secondary "## Configuration Sync"
    $MY/core/system/sync-files.zsh
    
    ui_secondary "## Dotfiles Linking"
    $MY/core/system/dotfiles.zsh
    
    ui_success_simple "System foundation ready"
}

setup_package_managers() {
    ui_spacer 2
    ui_primary "📦 Installing packages"
    
    ui_secondary "## Homebrew Formulae & Casks"
    if ! $MY/core/packages/brew.zsh; then
        exit 1
    fi
    
    ui_secondary "## Zsh Plugin Management"
    $MY/core/packages/antidote.zsh
    
    ui_secondary "## Ruby Gem Installation"
    $MY/core/packages/gem.zsh
    
    ui_secondary "## Python Package Installation"
    $MY/core/packages/pip.zsh
    
    ui_secondary "## Global npm Packages"
    $MY/core/packages/npm.zsh
    
    ui_secondary "## Mac App Store Applications"
    $MY/core/packages/mas.zsh
    
    ui_success_simple "All packages installed"
}

setup_development_tools() {
    ui_spacer 2
    ui_primary "🛠️ Configuring development tools"
    
    ui_secondary "## AI Commit Configuration"
    $MY/core/cli/aicommits.zsh
    
    ui_secondary "## Shell Abbreviations"
    $MY/core/cli/abbr.zsh
    
    ui_success_simple "Development tools configured"
}

setup_applications() {
    ui_spacer 2
    ui_primary "💻 Configuring applications"
    
    ui_secondary "## Sublime Merge Preferences"
    $MY/core/apps/sublime-merge.zsh
    
    ui_secondary "## KeePassXC Configuration"
    $MY/core/apps/keepassxc.zsh
    
    ui_success_simple "Applications configured"
}

setup_system_components() {
    ui_spacer 2
    ui_primary "🔌 Installing system components"
    
    ui_secondary "## Git Submodule Updates"
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
    
    ui_spacer 2
    ui_success_msg "Environment setup complete! ✨"
}

# Execute main setup
main