#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 ENVIRONMENT UPDATE MANAGER                                              #
#   ----------------------------                                              #
#   Updates the entire development environment including repository,           #
#   packages, and configurations to the latest versions.                      #
#                                                                              #
################################################################################

# Enable animated intro for update process
export MY_SHOW_INTRO="true"
source $MY/core/utils/intro.zsh

# Wait for animation to complete if it's running
if [[ -n "$MY_INTRO_PID" ]]; then
    wait $MY_INTRO_PID 2>/dev/null
    unset MY_INTRO_PID
fi

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

git --git-dir="$MY/.git" --work-tree="$MY/" pull || return 1

################################################################################
# 🔧 ENVIRONMENT REFRESH
################################################################################

$MY/core/main.zsh


################################################################################
# 🔄 CONFIGURATION ACTIVATION
################################################################################

source $HOME/.zshrc
