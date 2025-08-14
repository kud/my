#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🩺 ENVIRONMENT HEALTH CHECKER                                              #
#   -----------------------------                                              #
#   Performs comprehensive system health checks and diagnostics.              #
#   Validates package managers and development environment integrity.         #
#                                                                              #
################################################################################



################################################################################
# 🍺 PACKAGE MANAGER HEALTH
################################################################################

if command -v brew >/dev/null 2>&1; then
    echo "Checking package manager status"
    brew doctor

    if [[ $? -eq 0 ]]; then
        echo "Package manager is working properly"
    else
        echo "Package manager found issues that need attention"
    fi
else
    echo "Package manager not found - skipping health check"
fi

################################################################################
# 🔍 DEVELOPMENT TOOLS STATUS
################################################################################

echo "Verifying essential tools"

# Check for essential development tools
tools=(git zsh node npm)
missing_tools=()

for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "$tool is available"
    else
        echo "$tool is not installed"
        missing_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -eq 0 ]]; then
    echo "All essential tools are working properly! 🎉"
else
    echo "Missing essential tools: ${missing_tools[*]}"
    echo "Run the install command to fix these issues"
fi
