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
    if ! command -v mas >/dev/null 2>&1; then
        return 1
    fi
    
    # Ensure yq is installed
    ensure_yq_installed
}

################################################################################
# 🔄 MAS MAINTENANCE
################################################################################

update_mas_applications() {
    mas upgrade
}

merge_and_install_mas_packages() {
    local main_config=$(get_main_config_path "mas")
    local profile_config=$(get_profile_config_path "mas")
    
    # Install packages
    local all_packages=$(merge_yaml_items "$main_config" "$profile_config" '.packages[].id')
    if [[ -n "$all_packages" ]]; then
        echo "$all_packages" | while IFS= read -r package; do
            [[ -n "$package" ]] && mas_install "$package"
        done
    fi
    
    # Run post-install commands
    run_post_install_from_yaml "$main_config"
    run_post_install_from_yaml "$profile_config"
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

