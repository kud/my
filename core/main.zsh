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
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Cloud Storage Setup${UI_RESET}"
    $MY/core/apps/pcloud.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Default Directories${UI_RESET}"
    $MY/core/system/default-folders.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Configuration Sync${UI_RESET}"
    $MY/core/system/sync-files.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Dotfiles Linking${UI_RESET}"
    $MY/core/system/dotfiles.zsh
    
    ui_success_simple "System foundation ready"
}

setup_package_managers() {
    ui_spacer 2
    ui_primary "📦 Installing packages"
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Homebrew Formulae & Casks${UI_RESET}"
    if ! $MY/core/packages/brew.zsh; then
        exit 1
    fi
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Zsh Plugin Management${UI_RESET}"
    $MY/core/packages/antidote.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Ruby Gem Installation${UI_RESET}"
    $MY/core/packages/gem.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Python Package Installation${UI_RESET}"
    $MY/core/packages/pip.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Global npm Packages${UI_RESET}"
    $MY/core/packages/npm.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Mac App Store Applications${UI_RESET}"
    $MY/core/packages/mas.zsh
    
    ui_success_simple "All packages installed"
}

setup_development_tools() {
    ui_spacer 2
    ui_primary "🛠️ Configuring development tools"
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} AI Commit Configuration${UI_RESET}"
    $MY/core/cli/aicommits.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Shell Abbreviations${UI_RESET}"
    $MY/core/cli/abbr.zsh
    
    ui_success_simple "Development tools configured"
}

setup_applications() {
    ui_spacer 2
    ui_primary "💻 Configuring applications"
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Sublime Merge Preferences${UI_RESET}"
    $MY/core/apps/sublime-merge.zsh
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} KeePassXC Configuration${UI_RESET}"
    $MY/core/apps/keepassxc.zsh
    
    ui_success_simple "Applications configured"
}

setup_system_components() {
    ui_spacer 2
    ui_primary "🔌 Installing system components"
    
    echo -e "${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} Git Submodule Updates${UI_RESET}"
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