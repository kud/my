################################################################################
#                                                                              #
#   👤 PROFILE-SPECIFIC CONFIGURATION                                          #
#   ----------------------------------                                         #
#   Handles OS profile-specific settings and PATH configurations.              #
#                                                                              #
################################################################################

# Add profile-specific bins to PATH
# This requires OS_PROFILE to be set by local.zsh first
if [[ -n "$OS_PROFILE" ]]; then
  export PATH=$MY/profiles/$OS_PROFILE/bin/main:$PATH
  export PATH=$MY/profiles/$OS_PROFILE/bin/shims:$PATH
fi
