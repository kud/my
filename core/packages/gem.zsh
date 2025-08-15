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
ensure_command_available "gem" "Install Ruby from https://ruby-lang.org"

# Ensure yq is installed
ensure_command_available "yq" "Install with: brew install yq"

# Update gem system first
gem update --system
gem update

# Process gem packages using shared utilities
process_package_configs "gem" "gem_install"

