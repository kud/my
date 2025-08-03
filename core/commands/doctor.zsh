#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🩺 ENVIRONMENT HEALTH CHECKER                                              #
#   -----------------------------                                              #
#   Performs comprehensive system health checks and diagnostics.              #
#   Validates package managers and development environment integrity.         #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Checking environment health"
echo_space

################################################################################
# 🍺 PACKAGE MANAGER HEALTH
################################################################################

if command -v brew >/dev/null 2>&1; then
    echo_info "Checking package manager status"
    brew doctor

    if [[ $? -eq 0 ]]; then
        echo_space
        echo_success "Package manager is working properly"
    else
        echo_space
        echo_warn "Package manager found issues that need attention"
    fi
else
    echo_warn "Package manager not found - skipping health check"
fi

################################################################################
# 🔍 DEVELOPMENT TOOLS STATUS
################################################################################

echo_space
echo_info "Verifying essential tools"

# Check for essential development tools
tools=(git zsh node npm)
missing_tools=()

for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo_success "$tool is available"
    else
        echo_warn "$tool is not installed"
        missing_tools+=("$tool")
    fi
done

echo_space
if [[ ${#missing_tools[@]} -eq 0 ]]; then
    echo_task_done "Environment health check complete"
    echo_success "All essential tools are working properly! 🎉"
else
    echo_warn "Missing essential tools: ${missing_tools[*]}"
    echo_info "Run the install command to fix these issues"
fi
