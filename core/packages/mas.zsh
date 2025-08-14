#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🍎 MAC APP STORE MANAGER                                                   #
#   -------------------------                                                  #
#   Installs applications from the Mac App Store using mas command.           #
#   Uses DRY utilities for unified package management.                        #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up Mac App Store applications"

################################################################################
# 🔧 PREREQUISITES
################################################################################

ensure_mas_prerequisites() {
    # Check if mas is available
    if ! command -v mas >/dev/null 2>&1; then
        echo_fail "mas not found. Please install via Homebrew first."
        return 1
    fi

    echo_info "mas command is available"
}

################################################################################
# 🔄 MAS MAINTENANCE
################################################################################

update_mas_applications() {
    echo_info "Updating Mac App Store applications"
    mas upgrade
}

merge_and_install_mas_packages() {
    local main_config="$MY/config/packages/mas.yml"
    local profile_config="$MY/profiles/$OS_PROFILE/config/packages/mas.yml"
    
    echo_info "Merging Mac App Store configurations and installing packages"
    
    # Collect all packages
    local all_packages=""
    [[ -f "$main_config" ]] && all_packages+=$(yq eval '.packages[].id?' "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_packages+=$'\n'$(yq eval '.packages[].id?' "$profile_config" 2>/dev/null)
    
    # Install packages
    if [[ -n "$all_packages" ]]; then
        echo_info "Installing Mac App Store packages"
        echo "$all_packages" | sort -u | while IFS= read -r package; do
            [[ -n "$package" ]] && mas_install "$package"
        done
    fi
    
    # Collect and run all post-install commands
    local all_post_commands=""
    [[ -f "$main_config" ]] && all_post_commands+=$(yq eval '.post_install[]?' "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_post_commands+=$'\n'$(yq eval '.post_install[]?' "$profile_config" 2>/dev/null)
    
    if [[ -n "$all_post_commands" ]]; then
        echo_info "Running post-installation commands"
        echo "$all_post_commands" | while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                echo_info "Executing: $command"
                eval "$command"
            fi
        done
    fi
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

echo_task_done "Mac App Store setup completed successfully"
