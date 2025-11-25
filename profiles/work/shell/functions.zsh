#! /usr/bin/env zsh

# Source ui-kit if not already loaded
if ! typeset -f ui_warning_simple > /dev/null; then
  source "$MY/core/utils/ui-kit.zsh"
fi

# Override sudo to check for admin rights first
# If no admin rights, trigger Jamf Self Service policy to grant temporary admin access
sudo() {
  # Check if user is in admin group using dscl (more reliable than groups)
  local group_membership=$(dscl . -read /Groups/admin GroupMembership 2>/dev/null)
  if ! echo "$group_membership" | grep -q "\b$USER\b"; then
    # Run the automated Jamf request script silently
    local admin_script="$SYNC_FOLDER/Appdata/Raycast/scripts/commands/request-admin-privileges/index.js"
    (osascript -l JavaScript "$admin_script" &>/dev/null &)

    # Use ui-kit inline spinner
    local spinner_idx=0

    # Poll every 0.5 seconds for up to 30 seconds
    local attempts=0
    local max_attempts=60

    while [ $attempts -lt $max_attempts ]; do
      # Show spinner using ui-kit
      ui_spinner_tick "$spinner_idx" "Requesting admin rights..."
      spinner_idx=$(((spinner_idx + 1) % 10))

      sleep 0.5
      attempts=$((attempts + 1))

      # Check every 2 seconds (every 4th attempt)
      if (( attempts % 4 == 0 )); then
        group_membership=$(dscl . -read /Groups/admin GroupMembership 2>/dev/null)
        if echo "$group_membership" | grep -q "\b$USER\b"; then
          ui_spinner_clear
          ui_success_simple "Admin rights granted."
          command sudo "$@"
          return
        fi
      fi
    done

    # Timeout reached
    ui_spinner_clear
    ui_error_simple "Admin rights request timed out."
    return 1
  fi

  # Execute actual sudo command
  command sudo "$@"
}
