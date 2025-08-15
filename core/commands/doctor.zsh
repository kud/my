#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🩺 ENVIRONMENT HEALTH CHECKER                                              #
#   -----------------------------                                              #
#   Performs comprehensive system health checks and diagnostics.              #
#   Validates package managers and development environment integrity.         #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh

ui_spacer

################################################################################
# 🍺 PACKAGE MANAGER HEALTH
################################################################################

ui_primary "📦 Checking Homebrew"

if command -v brew >/dev/null 2>&1; then
    # Run brew doctor and capture output
    brew_output=$(brew doctor 2>&1)
    brew_status=$?
    
    if [[ $brew_status -eq 0 ]]; then
        ui_success_simple "Homebrew is healthy"
    else
        ui_warning_simple "Homebrew has issues"
        # Display brew doctor output with proper formatting
        echo "$brew_output" | while IFS= read -r line; do
            ui_muted "  $line"
        done
    fi
else
    ui_error_simple "Homebrew not installed"
fi

ui_spacer

################################################################################
# 🔍 DEVELOPMENT TOOLS STATUS
################################################################################

ui_primary "🛠️ Checking development tools"

# Check for essential development tools
tools=(git zsh node npm)
missing_tools=()
installed_tools=()

for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>&1 | head -1)
        installed_tools+=("$tool:$version")
        ui_success_simple "$tool installed"
        ui_muted "  $version"
    else
        missing_tools+=("$tool")
        ui_error_simple "$tool missing"
    fi
done

ui_spacer

################################################################################
# 📊 SUMMARY
################################################################################

if [[ ${#missing_tools[@]} -eq 0 ]]; then
    ui_success_msg "All systems operational! 🎉"
else
    ui_warning_msg "Missing tools detected"
    ui_muted "  Install with: brew install ${missing_tools[*]}"
fi

ui_spacer