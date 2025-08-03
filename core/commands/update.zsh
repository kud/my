#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 ENVIRONMENT UPDATE MANAGER                                              #
#   ----------------------------                                              #
#   Updates the entire development environment including repository,           #
#   packages, and configurations to the latest versions.                      #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

$MY/core/utils/intro.zsh

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

echo_info "Downloading latest updates"
git --git-dir="$MY/.git" --work-tree="$MY/" pull

if [[ $? -eq 0 ]]; then
    echo_success "Updates downloaded successfully"
else
    echo_fail "Failed to download updates"
    return 1
fi

################################################################################
# 🔧 ENVIRONMENT REFRESH
################################################################################

$MY/core/main.zsh

echo_space
echo_task_done "Environment update complete"

################################################################################
# 🔄 CONFIGURATION ACTIVATION
################################################################################

echo_info "Activating updated configuration"
source $HOME/.zshrc

echo_space
echo_success "Your environment is now up to date! 🚀"
