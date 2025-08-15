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

# Display header
ui_spacer
ui_panel "System Health Check" "Running comprehensive diagnostics on your development environment" "info"
ui_spacer

################################################################################
# 🍺 PACKAGE MANAGER HEALTH
################################################################################

ui_divider "─" 60 "$UI_PRIMARY"
ui_primary "📦 Package Manager Health"
ui_divider "─" 60 "$UI_PRIMARY"
ui_spacer

if command -v brew >/dev/null 2>&1; then
    ui_info_msg "Analyzing Homebrew configuration..."
    ui_spacer
    
    # Run brew doctor and capture output
    brew_output=$(brew doctor 2>&1)
    brew_status=$?
    
    if [[ $brew_status -eq 0 ]]; then
        ui_success_msg "Homebrew is operating perfectly"
        ui_muted "  No issues detected in package manager configuration"
    else
        ui_warning_msg "Homebrew reported configuration issues"
        ui_spacer
        # Display brew doctor output with proper formatting
        echo "$brew_output" | while IFS= read -r line; do
            ui_muted "  → $line"
        done
        ui_spacer
        ui_info_simple "Run 'brew doctor' for detailed diagnostics"
    fi
else
    ui_warning_msg "Homebrew not installed"
    ui_muted "  Package manager health check skipped"
fi

################################################################################
# 🔍 DEVELOPMENT TOOLS STATUS
################################################################################

ui_spacer
ui_divider "─" 60 "$UI_PRIMARY"
ui_primary "🛠️  Development Tools Status"
ui_divider "─" 60 "$UI_PRIMARY"
ui_spacer

# Check for essential development tools
tools=(git zsh node npm)
missing_tools=()
installed_tools=()

# Create a progress indicator for checking tools
total_tools=${#tools[@]}
current_tool=0

for tool in "${tools[@]}"; do
    ((current_tool++))
    ui_progress_bar $current_tool $total_tools 30 "▓" "░"
    
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>&1 | head -1)
        installed_tools+=("$tool:$version")
    else
        missing_tools+=("$tool")
    fi
done

ui_clear_line
ui_spacer

# Display results in a nice table format
if [[ ${#installed_tools[@]} -gt 0 ]]; then
    ui_success_simple "Installed Tools"
    for tool_info in "${installed_tools[@]}"; do
        tool_name="${tool_info%%:*}"
        tool_version="${tool_info#*:}"
        printf "  ${UI_SUCCESS}✓${UI_RESET} %-10s ${UI_MUTED}%s${UI_RESET}\n" "$tool_name" "$tool_version"
    done
fi

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    ui_spacer
    ui_error_simple "Missing Tools"
    for tool in "${missing_tools[@]}"; do
        printf "  ${UI_DANGER}✗${UI_RESET} %-10s ${UI_MUTED}Not installed${UI_RESET}\n" "$tool"
    done
fi

# Final status summary
ui_spacer
ui_divider "─" 60 "$UI_PRIMARY"

if [[ ${#missing_tools[@]} -eq 0 ]]; then
    ui_spacer
    ui_badge "success" " SYSTEM HEALTHY "
    ui_success_msg "All systems operational - ready for development!"
else
    ui_spacer
    ui_badge "warning" " ACTION REQUIRED "
    ui_warning_msg "Install missing tools to complete setup"
    ui_muted "  Run: brew install ${missing_tools[*]}"
fi

ui_spacer
