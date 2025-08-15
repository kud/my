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
source $MY/core/utils/intro.zsh

# Wait for animation to complete if it's running
if [[ -n "$MY_INTRO_PID" ]]; then
    wait $MY_INTRO_PID 2>/dev/null
    unset MY_INTRO_PID
fi

ui_spacer

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

ui_primary "🔄 Updating repository"
ui_muted "  $MY"

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

ui_primary "🔧 Updating environment"

# Run main update script
if $MY/core/main.zsh; then
    ui_success_simple "Environment updated"
else
    ui_error_msg "Environment update failed"
    exit 1
fi

ui_spacer

################################################################################
# 🔄 CONFIGURATION ACTIVATION
################################################################################

ui_primary "⚙️ Reloading configuration"

source $HOME/.zshrc

ui_success_simple "Configuration reloaded"

ui_spacer

################################################################################
# ✅ UPDATE COMPLETE
################################################################################

ui_success_msg "Update complete! 🎉"
ui_spacer