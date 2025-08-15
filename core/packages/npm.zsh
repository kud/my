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
ensure_command_available "npm" "Install Node.js from https://nodejs.org"

# Ensure yq is installed
ensure_command_available "yq" "Install with: brew install yq"

################################################################################
# 🔄 NPM SYSTEM UPDATE
################################################################################

npm update -g

# Process npm packages using shared utilities
process_package_configs "npm" "npm_install" "npm_install_run"

