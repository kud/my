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


# Check if Ruby and gem are available
if ! command -v gem >/dev/null 2>&1; then
    return 1
fi

################################################################################
# 🔄 GEM SYSTEM UPDATE
################################################################################

gem update --system && gem update

################################################################################
# 📦 ESSENTIAL RUBY GEMS
################################################################################


geminstall gist           # GitHub Gist command line interface
geminstall bundler        # Ruby dependency management
geminstall bundler-audit  # Security vulnerability scanner

