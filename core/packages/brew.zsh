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
source $MY/core/utils/package-manager-utils.zsh

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

    # Initialize brew cache for faster package checking
    init_brew_cache
}

merge_and_install_brew_packages() {
    local main_config=$(get_main_config_path "brew")
    local profile_config=$(get_profile_config_path "brew")
    
    # Install taps first
    local all_taps=$(merge_yaml_items "$main_config" "$profile_config" '.taps[]')
    if [[ -n "$all_taps" ]]; then
        echo "$all_taps" | while IFS= read -r tap; do
            [[ -n "$tap" ]] && brew_tap "$tap"
        done
    fi
    
    # Install formulae
    local all_formulae=$(merge_yaml_items "$main_config" "$profile_config" '.packages.formulae[]')
    if [[ -n "$all_formulae" ]]; then
        echo "$all_formulae" | while IFS= read -r formula; do
            [[ -n "$formula" ]] && brew_install "$formula"
        done
        brew_install_run
    fi
    
    # Install casks
    local all_casks=$(merge_yaml_items "$main_config" "$profile_config" '.packages.casks[]')
    if [[ -n "$all_casks" ]]; then
        echo "$all_casks" | while IFS= read -r cask; do
            [[ -n "$cask" ]] && cask_install "$cask"
        done
        cask_install_run
    fi
    
    # Run post-install commands
    run_post_install_from_yaml "$main_config"
    run_post_install_from_yaml "$profile_config"
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

