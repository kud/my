################################################################################
#                                                                              #
#   🏢 PROFILE-SPECIFIC CONFIGURATION                                          #
#   ----------------------------------                                         #
#   Loads profile-specific functions and settings.                            #
#                                                                              #
################################################################################

# Load profile-specific functions if OS_PROFILE is set
if [[ -n "$OS_PROFILE" ]]; then
  local profile_functions_dir="$MY/profiles/$OS_PROFILE/core/functions"

  # Source all function files in the profile's core/functions directory
  if [[ -d "$profile_functions_dir" ]]; then
    for func_file in "$profile_functions_dir"/*.zsh(N); do
      source "$func_file"
    done
  fi

  # Source profile-specific OS configurations if they exist
  local profile_os_main="$MY/profiles/$OS_PROFILE/core/os/main.zsh"
  if [[ -f "$profile_os_main" ]]; then
    source "$profile_os_main"
  fi
fi

################################################################################
