#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   💎 RUBY GEM MANAGER                                                        #
#   ------------------                                                         #
#   Manages Ruby gems installation and updates for development tools.         #
#   Installs essential gems for modern Ruby development workflow.              #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/package-manager-utils.zsh

# Check if Ruby and gem are available
if ! command -v gem >/dev/null 2>&1; then
    return 1
fi

# Ensure yq is installed
ensure_yq_installed

# Update gem system first
gem update --system
gem update

# Process gem packages using shared utilities
process_package_configs "gem" "gem_install"

