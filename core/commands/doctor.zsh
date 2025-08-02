#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🩺 SYSTEM HEALTH CHECKER                                                   #
#   -----------------------                                                    #
#   Performs comprehensive system health checks and diagnostics.              #
#   Validates package managers and development environment integrity.         #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Running system health diagnostics"
echo_space

################################################################################
# 🍺 HOMEBREW DIAGNOSTICS
################################################################################

if command -v brew >/dev/null 2>&1; then
    echo_info "Running Homebrew doctor diagnostics"
    brew doctor

    if [[ $? -eq 0 ]]; then
        echo_space
        echo_success "Homebrew system is healthy"
    else
        echo_space
        echo_warn "Homebrew found some issues that may need attention"
    fi
else
    echo_warn "Homebrew not found - skipping brew doctor"
fi

################################################################################
# 🔍 ADDITIONAL SYSTEM CHECKS
################################################################################

echo_space
echo_info "Checking development tools availability"

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
    echo_task_done "System health check completed"
    echo_success "All essential development tools are properly installed! 🎉"
else
    echo_warn "Missing tools detected: ${missing_tools[*]}"
    echo_info "Consider running the main installation script to resolve issues"
fi
