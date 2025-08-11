#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎯 ENVIRONMENT ORCHESTRATOR                                                 #
#   --------------------------                                                 #
#   Master orchestrator that executes all core system setup scripts in        #
#   the correct order for a complete development environment setup.           #
#                                                                              #
################################################################################

setopt EXTENDED_GLOB
source $MY/core/utils/helper.zsh

echo_task_start "Setting up your environment"

################################################################################
# 🔧 ENVIRONMENT COMPONENTS
################################################################################

echo_info "Installing essential components"
$MY/core/apps/pcloud.zsh         # Cloud storage setup
$MY/core/system/default-folders.zsh # Directory structure
$MY/core/system/sync-files.zsh     # Synchronized files (fonts, etc.)
$MY/core/system/dotfiles.zsh       # Personal configurations
$MY/core/packages/brew.zsh          # Homebrew packages
$MY/core/packages/antidote.zsh      # Shell enhancement
$MY/core/packages/gem.zsh           # Ruby packages
$MY/core/packages/pip.zsh           # Python packages
$MY/core/packages/npm.zsh           # Node.js packages
$MY/core/packages/mas.zsh           # Mac App Store apps
$MY/core/system/submodules.zsh    # Additional components
$MY/core/cli/neovim.zsh        # Text editor setup
$MY/core/cli/aicommits.zsh     # Smart commit messages
$MY/core/cli/abbr.zsh          # Command shortcuts
$MY/core/apps/sublime-merge.zsh # Git interface
$MY/core/apps/keepassxc.zsh     # Password manager

echo_space
echo_task_done "Environment setup completed successfully"
echo_success "All essential components are now ready!"
