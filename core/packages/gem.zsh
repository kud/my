#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   💎 RUBY GEM MANAGER                                                        #
#   ------------------                                                         #
#   Manages Ruby gems installation and updates for development tools.         #
#   Installs essential gems for modern Ruby development workflow.              #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up Ruby gems"
echo_space

# Check if Ruby and gem are available
if ! command -v gem >/dev/null 2>&1; then
    echo_fail "Ruby gems not found. Please install Ruby first."
    return 1
fi

################################################################################
# 🔄 GEM SYSTEM UPDATE
################################################################################

echo_info "Updating gem system and existing gems"
gem update --system && gem update

echo_space
echo_success "Gem system updated successfully"

################################################################################
# 📦 ESSENTIAL RUBY GEMS
################################################################################

echo_info "Installing essential Ruby development gems"

geminstall gist           # GitHub Gist command line interface
geminstall bundler        # Ruby dependency management
geminstall bundler-audit  # Security vulnerability scanner

echo_space
echo_task_done "Ruby gems configuration completed"
echo_success "Essential Ruby development tools are now available!"
