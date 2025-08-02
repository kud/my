#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎯 CORE SYSTEM INSTALLER                                                   #
#   ----------------------                                                     #
#   Master orchestrator that executes all core system setup scripts in        #
#   the correct order for a complete development environment setup.           #
#                                                                              #
################################################################################

setopt EXTENDED_GLOB
source $MY/core/utils/helper.zsh

echo_task_start "Initializing core system setup"
echo_space

################################################################################
# 🔧 CORE SYSTEM COMPONENTS
################################################################################

echo_info "Executing core installation sequence"
$MY/core/apps/pcloud.zsh         # Cloud storage synchronization
$MY/core/system/default-folders.zsh # Create default directories
$MY/core/system/dotfiles.zsh       # User configuration files
$MY/core/packages/brew.zsh          # Package manager and system tools
$MY/core/packages/antidote.zsh      # Zsh plugin manager
$MY/core/packages/gem.zsh           # Ruby package management
$MY/core/packages/pip.zsh           # Python package management
$MY/core/packages/npm.zsh           # Node.js package management
$MY/core/packages/mas.zsh           # Mac App Store applications
$MY/core/system/submodules.zsh    # Git submodule dependencies
$MY/core/cli/neovim.zsh        # Text editor configuration
$MY/core/cli/aicommits.zsh     # AI-powered commit messages
$MY/core/cli/abbr.zsh          # Shell abbreviations
$MY/core/apps/sublime-merge.zsh # Git GUI client
$MY/core/apps/keepassxc.zsh     # Password manager

echo_space
echo_task_done "Core system setup completed successfully"
echo_space
echo_success "All core components have been installed and configured!"
