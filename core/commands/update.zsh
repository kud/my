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

# Display update header
ui_spacer
ui_center_text "🔄 ENVIRONMENT UPDATE"
ui_divider "═" 60 "$UI_PRIMARY"
ui_spacer

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

ui_panel "Step 1: Repository Sync" "Pulling latest changes from remote" "info"
ui_spacer

ui_info_msg "Updating repository..."
ui_muted "  Location: $MY"
ui_spacer

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
                ui_success_simple "Updates downloaded successfully"
            elif [[ "$line" == *"files changed"* ]]; then
                ui_info_simple "$line"
            elif [[ "$line" == *"|"* ]]; then
                ui_muted "  $line"
            fi
        done
    fi
else
    ui_error_msg "Failed to update repository"
    ui_muted "  Error: $git_output"
    ui_spacer
    ui_warning_simple "Please check your network connection and try again"
    exit 1
fi

ui_spacer

################################################################################
# 🔧 ENVIRONMENT REFRESH
################################################################################

ui_panel "Step 2: Environment Update" "Refreshing packages and configurations" "info"
ui_spacer

ui_info_msg "Running system update..."
ui_muted "  This may take a few minutes"
ui_spacer

# Show progress indicator while updating
ui_dots_loading 2 "Updating environment"

# Run main update script
if $MY/core/main.zsh; then
    ui_success_msg "Environment updated successfully"
else
    ui_error_msg "Environment update failed"
    ui_muted "  Check the output above for errors"
    exit 1
fi

ui_spacer

################################################################################
# 🔄 CONFIGURATION ACTIVATION
################################################################################

ui_panel "Step 3: Configuration" "Reloading shell configuration" "info"
ui_spacer

ui_info_msg "Applying new configuration..."
source $HOME/.zshrc

ui_success_simple "Configuration reloaded"
ui_spacer

################################################################################
# ✅ UPDATE COMPLETE
################################################################################

ui_divider "═" 60 "$UI_SUCCESS"
ui_spacer

ui_badge "success" " UPDATE COMPLETE "
ui_spacer

ui_success_msg "Environment successfully updated! 🎉"
ui_spacer

ui_info_simple "Summary:"
ui_muted "  • Repository synchronized"
ui_muted "  • Packages updated"
ui_muted "  • Configuration reloaded"
ui_spacer

ui_primary "Your development environment is now up to date!"
ui_spacer