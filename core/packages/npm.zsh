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
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# Check if Node.js and npm are available
ensure_command_available "npm" "Install Node.js from https://nodejs.org"

# Ensure yq is installed
ensure_command_available "yq" "Install with: brew install yq"

################################################################################
# 🔄 NPM SYSTEM UPDATE
################################################################################

ui_info_simple "Updating npm packages..."
npm update -g
ui_success_simple "npm packages updated"

ui_spacer

# Process npm packages using shared utilities
process_package_configs "npm" "npm_install" "npm_install_run"
ui_success_simple "npm packages installed"

