#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 NODE.JS PACKAGE MANAGER                                                 #
#   -------------------------                                                  #
#   Manages global npm packages for development tools and CLI utilities.      #
#   Installs essential Node.js tools for modern web development workflow.     #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/package-manager-utils.zsh

# Check if Node.js and npm are available
if ! command -v npm >/dev/null 2>&1; then
    return 1
fi

# Ensure yq is installed
ensure_yq_installed

################################################################################
# 🔄 NPM SYSTEM UPDATE
################################################################################

npm update -g

# Process npm packages using shared utilities
process_package_configs "npm" "npm_install" "npm_install_run"

