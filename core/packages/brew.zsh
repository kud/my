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

source $MY/core/utils/helper.zsh
source $MY/core/utils/package-manager.zsh
source $MY/core/utils/profile-manager.zsh

echo_task_start "Setting up Homebrew package manager"

################################################################################
# 🔧 PREREQUISITES
################################################################################

ensure_homebrew_prerequisites() {
    # Check if yq is available for YAML parsing
    if ! command -v yq >/dev/null 2>&1; then
        echo_info "Installing yq for YAML parsing"
        brew install yq
    fi
}

################################################################################
# 🍺 HOMEBREW INSTALLATION
################################################################################

install_homebrew_if_needed() {
    if ! command -v brew >/dev/null 2>&1; then
        echo_info "Installing Homebrew package manager"
        sudo -v
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if command -v brew >/dev/null 2>&1; then
            echo_success "Homebrew installed successfully"
        else
            echo_fail "Failed to install Homebrew"
            return 1
        fi
    else
        echo_info "Homebrew already installed"
    fi
}

################################################################################
# 🐚 SHELL CONFIGURATION
################################################################################

configure_modern_shell() {
    # Use modern zsh from Homebrew if using system zsh
    if [[ $(which zsh) == "/bin/zsh" ]]; then
        echo_info "Installing modern zsh shell via Homebrew"
        brewinstall zsh
        echo "${HOMEBREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
        chsh -s ${HOMEBREW_PREFIX}/bin/zsh
        echo_success "Homebrew zsh configured as default shell"
    fi

    # Use modern bash from Homebrew if using system bash
    if [[ $(which bash) == "/bin/bash" ]]; then
        echo_info "Installing modern bash shell via Homebrew"
        brewinstall bash
        echo "${HOMEBREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
        echo_success "Homebrew bash configured"
    fi
}

################################################################################
# 🔄 HOMEBREW MAINTENANCE
################################################################################

update_homebrew() {
    echo_info "Updating Homebrew and packages"
    brew update && brew upgrade

    # Initialize brew cache for faster package checking
    init_brew_cache
}

################################################################################
# � MAIN EXECUTION
################################################################################

main() {
    # Validate profile
    detect_and_validate_profile

    # Install Homebrew if needed
    install_homebrew_if_needed

    # Configure shell
    configure_modern_shell

    # Update Homebrew
    update_homebrew

    # Ensure prerequisites
    ensure_homebrew_prerequisites

    # Install all packages using unified package manager
    install_merged_packages "brew"
}

# Execute main function
main

echo_task_done "Homebrew setup completed successfully"
