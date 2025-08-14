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

# 🔧 PREREQUISITES
################################################################################

ensure_homebrew_prerequisites() {
    # Check if yq is available for YAML parsing
    if ! command -v yq >/dev/null 2>&1; then
        brew install yq
    fi
}

################################################################################
# 🍺 HOMEBREW INSTALLATION
################################################################################

install_homebrew_if_needed() {
    if ! command -v brew >/dev/null 2>&1; then
        sudo -v
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if ! command -v brew >/dev/null 2>&1; then
            return 1
        fi
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
    local main_config="$MY/config/packages/brew.yml"
    local profile_config="$MY/profiles/$OS_PROFILE/config/packages/brew.yml"
    
    
    # Collect all taps
    local all_taps=""
    [[ -f "$main_config" ]] && all_taps+=$(yq eval '.taps[]?' "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_taps+=$'\n'$(yq eval '.taps[]?' "$profile_config" 2>/dev/null)
    
    # Install taps first
    if [[ -n "$all_taps" ]]; then
        echo "$all_taps" | sort -u | while IFS= read -r tap; do
            [[ -n "$tap" ]] && brew_tap "$tap"
        done
    fi
    
    # Collect all formulae
    local all_formulae=""
    [[ -f "$main_config" ]] && all_formulae+=$(yq eval '.packages.formulae[]?' "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_formulae+=$'\n'$(yq eval '.formulae[]?' "$profile_config" 2>/dev/null)
    
    # Install formulae
    if [[ -n "$all_formulae" ]]; then
        echo "$all_formulae" | sort -u | while IFS= read -r formula; do
            [[ -n "$formula" ]] && brew_install "$formula"
        done
        brew_install_run
    fi
    
    # Collect all casks
    local all_casks=""
    [[ -f "$main_config" ]] && all_casks+=$(yq eval '.packages.casks[]?' "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_casks+=$'\n'$(yq eval '.casks[]?' "$profile_config" 2>/dev/null)
    
    # Install casks
    if [[ -n "$all_casks" ]]; then
        echo "$all_casks" | sort -u | while IFS= read -r cask; do
            [[ -n "$cask" ]] && cask_install "$cask"
        done
        cask_install_run
    fi
    
    # Collect and run all post-install commands
    local all_post_commands=""
    [[ -f "$main_config" ]] && all_post_commands+=$(yq eval '.post_install[]?' "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_post_commands+=$'\n'$(yq eval '.post_install[]?' "$profile_config" 2>/dev/null)
    
    if [[ -n "$all_post_commands" ]]; then
        echo "$all_post_commands" | while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command"
            fi
        done
    fi
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

