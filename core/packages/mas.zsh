#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🍎 MAC APP STORE MANAGER                                                   #
#   -------------------------                                                  #
#   Installs applications from the Mac App Store using mas command.           #
#   Uses DRY utilities for unified package management.                        #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/package-manager-utils.zsh

################################################################################
# 🔧 PREREQUISITES
################################################################################

ensure_mas_prerequisites() {
    # Check if mas is available
    ensure_command_available "mas" "Install with: brew install mas"
    
    # Ensure yq is installed
    ensure_command_available "yq" "Install with: brew install yq"
}

################################################################################
# 🔄 MAS MAINTENANCE
################################################################################

update_mas_applications() {
    mas upgrade
}

merge_and_install_mas_packages() {
    merge_and_install_packages "mas" ".packages[].id:mas_install:-"
}

################################################################################
# 🚀 MAIN EXECUTION
################################################################################

main() {
    # Ensure prerequisites
    ensure_mas_prerequisites

    # Merge configs and install packages
    merge_and_install_mas_packages

    # Update existing applications
    update_mas_applications
}

# Execute main function
main

