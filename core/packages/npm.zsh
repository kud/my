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

# @FIXME This section is a temporary workaround to handle npm package updates
# Clean up any temporary npm rename directories before update
# npm creates these as .<package-name>-<random> during failed installs
local npm_prefix=$(npm config get prefix)
if [[ -d "$npm_prefix/lib/node_modules" ]]; then
    # Remove directories matching npm's temporary rename pattern (starts with dot, contains dash)
    find "$npm_prefix/lib/node_modules" -type d -name ".*-*" -exec rm -rf {} + 2>/dev/null || true
fi

ui_subsection "Updating npm packages"
npm update -g
ui_success_simple "npm packages updated" 1

ui_spacer

ui_subsection "Ensuring npm CLI latest"
if npm install -g npm@latest; then
  ui_success_simple "npm CLI updated" 1
else
  ui_warning_simple "npm CLI update failed"
fi

ui_spacer

# Process npm packages using shared utilities
process_package_configs "npm" "npm_install" "npm_install_run"
ui_success_simple "npm packages installed" 1
