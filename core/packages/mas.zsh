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
        local main_config="$CONFIG_DIR/packages/mas.yml"
        local profile_config="$PROFILE_CONFIG_DIR/packages/mas.yml"
        
        # Collect app names from both configs
        local apps_found=""
        if [[ -f "$main_config" ]]; then
            local main_apps=$(yq eval '.packages[]?.name // empty' "$main_config" 2>/dev/null)
            if [[ -n "$main_apps" ]]; then
                apps_found+="$main_apps"
            fi
        fi
        if [[ -f "$profile_config" ]]; then
            local profile_apps=$(yq eval '.packages[]?.name // empty' "$profile_config" 2>/dev/null)
            if [[ -n "$profile_apps" ]]; then
                [[ -n "$apps_found" ]] && apps_found+=$'\n'
                apps_found+="$profile_apps"
            fi
        fi
        
        # Show the apps if we found any
        if [[ -n "$apps_found" ]]; then
            ui_info_simple "Installing Mac App Store applications:"
            echo "$apps_found" | while read app_name; do
                if [[ -n "$app_name" && "$app_name" != "null" ]]; then
                    echo "  • $app_name"
                fi
            done
        fi
    fi
    
    merge_and_install_packages "mas" ".packages[].id:mas_install:-"
    ui_success_simple "Mac App Store applications processed"
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

