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
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# Check if Ruby and gem are available
ensure_command_available "gem" "Install Ruby from https://ruby-lang.org"

# Ensure yq is installed
ensure_command_available "yq" "Install with: brew install yq"

# Update gem system first
ui_subsection "Updating gem system"
gem update --system
ui_success_simple "Gem system updated"

ui_spacer

ui_subsection "Updating installed gems"
gem update
ui_success_simple "Installed gems updated"

ui_spacer

# Process gem packages using shared utilities
ui_subsection "Installing development gems"
process_package_configs "gem" "gem_install"
ui_success_simple "Development gems installation completed"

