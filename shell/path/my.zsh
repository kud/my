################################################################################
#                                                                              #
#   🔧 MY BINS PATH SETUP                                                     #
#   -------------------                                                       #
#   Custom bin directories for personal tools and utilities.                   #
#                                                                              #
################################################################################

# Own commands
export PATH=$MY/bin:$PATH

# Own utilities
export PATH=$MY/bin/main:$PATH

# Git commands
export PATH=$MY/bin/git:$PATH

# Profile-specific bins (requires OS_PROFILE to be set by local.zsh first)
if [[ -n "$OS_PROFILE" ]]; then
  export PATH=$MY/profiles/$OS_PROFILE/bin/main:$PATH
  export PATH=$MY/profiles/$OS_PROFILE/bin/shims:$PATH
fi
