#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🐍 PYTHON PACKAGE MANAGER                                                  #
#   ------------------------                                                   #
#   Manages Python via mise and pip packages.                                  #
#   Installs latest Python and essential development packages.                #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# Ensure yq is installed
ensure_command_available "yq" "Install with: brew install yq"

################################################################################
# 🐍 PYTHON INSTALLATION VIA MISE
################################################################################

# Ensure mise is available
if ensure_command_available "mise" "Install with: brew install mise" "false"; then
    # Determine the latest stable Python version via mise
    local _PIP_LATEST_PYTHON_VERSION=$(mise ls-remote python | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)

    if [[ -n "$_PIP_LATEST_PYTHON_VERSION" ]]; then
        ui_subsection "Installing Python $_PIP_LATEST_PYTHON_VERSION via mise"
        mise install python@$_PIP_LATEST_PYTHON_VERSION
        mise use -g python@$_PIP_LATEST_PYTHON_VERSION
        ui_success_simple "Python $_PIP_LATEST_PYTHON_VERSION installed and set globally via mise"
    else
        ui_warning "Could not determine latest Python version via mise"
    fi
fi

ui_spacer

################################################################################
# 📦 PIP PACKAGES & UPDATES
################################################################################

# Custom pip install function for use with shared utilities
pip_install_package() {
    local package="$1"
    pip install "$package"
}

# Check if pip is available
if ensure_command_available "pip" "" "false"; then
    # Upgrade pip itself first
    ui_subsection "Upgrading pip"
    pip install --upgrade pip
    ui_success_simple "pip upgraded" 1

    ui_spacer

    # Process pip packages using shared utilities
    ui_subsection "Installing development packages"
    process_package_configs "pip" "pip_install_package"
    ui_success_simple "Development packages installed" 1

    ui_spacer

    # Upgrade all installed packages
    ui_subsection "Upgrading all installed packages"
    pip-upgrade-all
    ui_success_simple "All packages upgraded" 1
fi

