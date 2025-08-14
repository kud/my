#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 ENVIRONMENT UPDATE MANAGER                                              #
#   ----------------------------                                              #
#   Updates the entire development environment including repository,           #
#   packages, and configurations to the latest versions.                      #
#                                                                              #
################################################################################


$MY/core/utils/intro.zsh

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

echo "Downloading latest updates"
git --git-dir="$MY/.git" --work-tree="$MY/" pull

if [[ $? -eq 0 ]]; then
    echo "Updates downloaded successfully"
else
    echo "Failed to download updates" >&2
    return 1
fi

################################################################################
# 🔧 ENVIRONMENT REFRESH
################################################################################

$MY/core/main.zsh


################################################################################
# 🔄 CONFIGURATION ACTIVATION
################################################################################

echo "Activating updated configuration"
source $HOME/.zshrc

echo "Environment is now up to date! 🚀"
