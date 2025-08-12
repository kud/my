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
source $MY/core/utils/unified-installer.zsh

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

################################################################################
# 🚀 MAIN EXECUTION
################################################################################

main() {
    # Ensure prerequisites
    ensure_mas_prerequisites

    # Install packages using unified installer
    install_merged_packages "mas"

    # Update existing applications
    update_mas_applications
}

# Execute main function
main

echo_task_done "Mac App Store setup completed successfully"
