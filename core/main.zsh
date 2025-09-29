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
    ui_section "${UI_ICON_TOOLS} Setting up system foundation"
    ui_subtitle "Cloud Storage Setup"
    $MY/core/apps/pcloud.zsh

    ui_subtitle "Default Directories"
    $MY/core/system/default-folders.zsh

    ui_subtitle "Configuration Sync"
    $MY/core/system/sync-files.zsh

    ui_subtitle "Dotfiles Linking"
    $MY/core/system/dotfiles.zsh

    ui_subtitle "Symbolic Links"
    $MY/core/system/symlinks.zsh

    ui_success_simple "System foundation ready" 1
}

setup_package_managers() {
    ui_section "${UI_ICON_INSTALL} Installing packages"
    ui_subtitle "Homebrew Formulae & Casks"
    if ! $MY/core/packages/brew.zsh; then
        exit 1
    fi

    # Run mise early so language globals are current before package installs
    ui_subtitle "mise Tool Sync"
    if command -v mise >/dev/null 2>&1; then
        $MY/core/packages/mise.zsh || ui_warning_simple "mise sync failed" # relocated from core/mise.zsh
    else
        ui_warning_simple "mise not found (brew install mise)"
    fi

    ui_subtitle "GitHub CLI Extensions"
    $MY/core/packages/gh.zsh

    ui_subtitle "Zsh Plugins"
    $MY/core/packages/antidote.zsh

    ui_subtitle "Ruby Gems"
    $MY/core/packages/gem.zsh

    ui_subtitle "Python Packages"
    $MY/core/packages/pip.zsh

    ui_subtitle "Node.js Packages"
    $MY/core/packages/npm.zsh

    ui_subtitle "Mac App Store"
    $MY/core/packages/mas.zsh

    ui_success_simple "All packages installed" 1
}

setup_development_tools() {
    ui_section "${UI_ICON_TOOLS} Configuring development tools"
    ui_subtitle "Shell Abbreviations"
    $MY/core/cli/abbr.zsh

    ui_subtitle "Opencode Configuration"
    $MY/core/cli/opencode.zsh

    ui_success_simple "Development tools configured" 1
}

setup_applications() {
    ui_section "${UI_ICON_COMPUTER} Configuring applications"
    ui_subtitle "Sublime Merge Preferences"
    $MY/core/apps/sublime-merge.zsh

    ui_subtitle "KeePassXC Configuration"
    $MY/core/apps/keepassxc.zsh

    ui_subtitle "Bruno Preferences"
    $MY/core/apps/bruno.zsh

    ui_success_simple "Applications configured"
}

setup_system_components() {
    ui_section "${UI_ICON_PLUG} Installing system components"
    ui_subtitle "Git Submodule Updates"
    $MY/core/system/submodules.zsh

    ui_subtitle "System Services"
    $MY/core/system/services.zsh start --all

    ui_success_simple "System components ready"
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
}

# Execute main setup
main
