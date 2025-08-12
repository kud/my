#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 UNIFIED PACKAGE INSTALLER                                               #
#   ----------------------------                                              #
#   Generic script that can install any type of packages using the            #
#   unified package management system. Reduces code duplication across        #
#   individual package manager scripts.                                       #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/package-manager.zsh
source $MY/core/utils/profile-manager.zsh

################################################################################
# 🎯 USAGE FUNCTIONS
################################################################################

show_usage() {
    echo "Usage: $0 <package_manager>"
    echo ""
    echo "Supported package managers:"
    echo "  brew    - Homebrew formulae and casks"
    echo "  mas     - Mac App Store applications"
    echo "  npm     - Node.js packages"
    echo "  pip     - Python packages"
    echo "  gem     - Ruby gems"
    echo ""
    echo "Examples:"
    echo "  $0 brew    # Install all Homebrew packages"
    echo "  $0 npm     # Install all npm packages"
}

################################################################################
# 🚀 MAIN EXECUTION
################################################################################

main() {
    local package_manager="$1"

    if [[ -z "$package_manager" ]]; then
        echo_fail "Package manager not specified"
        show_usage
        return 1
    fi

    case "$package_manager" in
        "brew"|"homebrew")
            install_merged_packages "brew"
            ;;
        "mas"|"appstore")
            install_merged_packages "mas"
            ;;
        "npm"|"node")
            install_merged_packages "npm"
            ;;
        "pip"|"python")
            install_merged_packages "pip"
            ;;
        "gem"|"ruby")
            install_merged_packages "gem"
            ;;
        "all")
            echo_task_start "Installing all packages from all managers"
            install_merged_packages "brew"
            install_merged_packages "mas"
            install_merged_packages "npm"
            install_merged_packages "pip"
            install_merged_packages "gem"
            echo_task_done "All packages installation completed"
            ;;
        *)
            echo_fail "Unsupported package manager: $package_manager"
            show_usage
            return 1
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
