################################################################################
#                                                                              #
#   👤 PROFILES PATH SETUP                                                    #
#   --------------------                                                      #
#   Profile-specific PATH modifications (work, home, etc).                     #
#                                                                              #
################################################################################

# Profile-specific bins (requires OS_PROFILE to be set by local.zsh first)
if [[ -n "$OS_PROFILE" ]]; then
  export PATH=$MY/profiles/$OS_PROFILE/bin/main:$PATH
  export PATH=$MY/profiles/$OS_PROFILE/bin/shims:$PATH
fi
