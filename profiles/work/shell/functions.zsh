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
    ui_info_simple "Requesting admin rights..."

    # Run the automated Jamf request script silently
    local admin_script="$SYNC_FOLDER/Appdata/Raycast/scripts/commands/request-admin-privileges/index.js"
    (osascript -l JavaScript "$admin_script" &>/dev/null &)

    # Poll every 2 seconds for up to 30 seconds
    local attempts=0
    local max_attempts=15

    while [ $attempts -lt $max_attempts ]; do
      sleep 2
      attempts=$((attempts + 1))

      # Check if admin rights were granted
      group_membership=$(dscl . -read /Groups/admin GroupMembership 2>/dev/null)
      if echo "$group_membership" | grep -q "\b$USER\b"; then
        ui_success_simple "Admin rights granted."
        command sudo "$@"
        return
      fi
    done

    # Timeout reached
    ui_error_simple "Admin rights request timed out."
    return 1
  fi

  # Execute actual sudo command
  command sudo "$@"
}
