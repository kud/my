################################################################################
#                                                                              #
#   👤 PROFILE-SPECIFIC CONFIGURATION                                          #
#   -----------------------------------                                        #
#   Loads profile-specific shell configurations (home/work).                   #
#                                                                              #
################################################################################

# Load profile-specific shell functions and configurations
if [[ -n "$OS_PROFILE" && -d "$MY/profiles/$OS_PROFILE/shell" ]]; then
  for profile_module in "$MY/profiles/$OS_PROFILE/shell"/*.zsh; do
    [[ -f "$profile_module" ]] && source "$profile_module"
  done
fi

################################################################################
