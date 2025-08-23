#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 ENVIRONMENT UPDATE MANAGER                                              #
#   ----------------------------                                              #
#   Updates the entire development environment including repository,           #
#   packages, and configurations to the latest versions.                      #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh

# Enable animated intro for update process
export MY_SHOW_INTRO="true"

# Run the animation directly (synchronously) for better display
source $MY/core/utils/intro.zsh
if [[ -z "$CI" ]] && [[ -t 1 ]]; then
    show_animated_intro
fi

################################################################################
# 📋 ENVIRONMENT INFO
################################################################################

# Get version info
MY_VERSION=$(git --git-dir="$MY/.git" describe --tags --always 2>/dev/null || echo "unknown")
HOSTNAME=$(hostname -s)
PROFILE="${OS_PROFILE:-default}"

ui_info_simple "Version: $MY_VERSION"
ui_info_simple "Host: $HOSTNAME"
ui_info_simple "Profile: $PROFILE"

ui_spacer

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

ui_section "🔄 Updating repository"
ui_info_simple "Path: $MY"

# Capture git output for better formatting
git_output=$(git --git-dir="$MY/.git" --work-tree="$MY/" pull 2>&1)
git_status=$?

if [[ $git_status -eq 0 ]]; then
    if [[ "$git_output" == *"Already up to date"* ]]; then
        ui_success_simple "Repository already up to date"
    else
        # Show what was updated
        echo "$git_output" | while IFS= read -r line; do
            if [[ "$line" == *"Fast-forward"* ]]; then
                ui_success_simple "Updates downloaded"
            elif [[ "$line" == *"files changed"* ]]; then
                ui_info_simple "$line"
            elif [[ "$line" == *"|"* ]]; then
                ui_muted "  $line"
            fi
        done
    fi
else
    ui_error_msg "Failed to update repository"
    echo "$git_output" | while IFS= read -r line; do
        ui_muted "  $line"
    done
    exit 1
fi

ui_spacer

################################################################################
# 🔧 ENVIRONMENT REFRESH
################################################################################

ui_section "🔧 Updating environment"

# Run main update script
if ! $MY/core/main.zsh; then
    ui_error_msg "Environment update failed"
    exit 1
fi

ui_spacer

################################################################################
# ✅ UPDATE COMPLETE
################################################################################

ui_primary "Update complete! 🎉"
