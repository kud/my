#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🍺 HOMEBREW PACKAGE MANAGER                                                #
#   -------------------------                                                  #
#   Installs and configures Homebrew with essential packages, casks, and      #
#   development tools for a complete macOS development environment.           #
#   Uses DRY utilities for unified package management.                        #
#                                                                              #
################################################################################

# Source required utilities (for package installation functions)
source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# 🔧 PREREQUISITES
################################################################################

ensure_homebrew_prerequisites() {
    # Ensure yq is installed
    ensure_command_available "yq" "Install with: brew install yq"
}

################################################################################
# 🍺 HOMEBREW INSTALLATION
################################################################################

install_homebrew_if_needed() {
    if ! ensure_command_available "brew" "" "false"; then
        sudo -v
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        ensure_command_available "brew" "Install from https://brew.sh"
    fi
}

################################################################################
# 🐚 SHELL CONFIGURATION
################################################################################

configure_modern_shell() {
    # Use modern zsh from Homebrew if using system zsh
    if [[ $(which zsh) == "/bin/zsh" ]]; then
        brew_install zsh
        echo "${HOMEBREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
        chsh -s ${HOMEBREW_PREFIX}/bin/zsh
    fi

    # Use modern bash from Homebrew if using system bash
    if [[ $(which bash) == "/bin/bash" ]]; then
        brew_install bash
        echo "${HOMEBREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    fi
}

################################################################################
# 🔄 HOMEBREW MAINTENANCE
################################################################################

update_homebrew() {
    brew update && brew upgrade
    ui_success_simple "Homebrew updated"
    ui_space

    # Initialize brew cache for faster package checking
    init_brew_cache
}

merge_and_install_brew_packages() {
    merge_and_install_packages "brew" \
        ".taps[]:brew_tap:-" \
        ".packages.formulae[]:brew_install:brew_install_run" \
        ".packages.casks[]:cask_install:cask_install_run"
    ui_success_simple "Homebrew packages installed"
}

################################################################################
# � MAIN EXECUTION
################################################################################

main() {
    # Install Homebrew if needed
    install_homebrew_if_needed

    # Configure shell
    configure_modern_shell

    # Update Homebrew
    update_homebrew

    # Ensure prerequisites
    ensure_homebrew_prerequisites

    # Merge configs and install packages
    merge_and_install_brew_packages
}

# Execute main function
main

