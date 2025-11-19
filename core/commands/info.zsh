#!/usr/bin/env zsh

# Environment info summary
# ------------------------
# Lightweight command to display the current my
# environment context (version, host, profile)
# without running any updates.

source "$MY/core/utils/ui-kit.zsh"

# Get version info
MY_VERSION=$(git --git-dir="$MY/.git" describe --tags --always 2>/dev/null || echo "unknown")
HOSTNAME=$(hostname -s)
PROFILE="${OS_PROFILE:-default}"

# Display environment info as a table for better readability
headers=$'Version	Host	Profile'
rows=$MY_VERSION$'\t'$HOSTNAME$'\t'$PROFILE

ui_table "$headers" "$rows"
