#! /usr/bin/env zsh

# Wrapper for sudo that ensures admin privileges are granted via Jamf first
function sudo() {
  # Check if user is in admin group
  if ! groups | grep -q '\badmin\b'; then
    echo "⚠️  Not currently an admin. Requesting admin privileges via Jamf..."

    # Run Jamf Self Service policy to grant admin rights
    open "jamfselfservice://content?entity=policy&id=2674&action=execute"

    # Wait a moment for the policy to process
    echo "⏳ Waiting for admin privileges to be granted..."
    sleep 3

    # Check if we're admin now
    local max_attempts=10
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
      if groups | grep -q '\badmin\b'; then
        echo "✅ Admin privileges granted!"
        break
      fi
      sleep 2
      attempt=$((attempt + 1))
    done

    if ! groups | grep -q '\badmin\b'; then
      echo "❌ Failed to obtain admin privileges. Please run the Jamf policy manually."
      return 1
    fi
  fi

  # Run the actual sudo command
  command sudo "$@"
}
