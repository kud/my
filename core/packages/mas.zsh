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
source $MY/core/utils/ui-kit.zsh

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
    ui_info_simple "Checking for Mac App Store updates..."
    mas upgrade
    ui_success_simple "Mac App Store apps updated"
}

merge_and_install_mas_packages() {
    # Show what we're about to install
    if command -v yq >/dev/null 2>&1; then
        local apps_to_install=$(yq eval '.packages[].name' "$CONFIG_DIR/packages/mas.yml" "$PROFILE_CONFIG_DIR/packages/mas.yml" 2>/dev/null | grep -v null | sort -u)
        if [[ -n "$apps_to_install" ]]; then
            ui_info_simple "Installing Mac App Store applications:"
            echo "$apps_to_install" | while read app_name; do
                if [[ -n "$app_name" ]]; then
                    ui_info_simple "  • $app_name"
                fi
            done
        fi
    fi
    
    merge_and_install_packages "mas" ".packages[].id:mas_install:-"
    ui_success_simple "Mac App Store applications installed"
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

