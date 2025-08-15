#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🐍 PYTHON PACKAGE MANAGER                                                  #
#   ------------------------                                                   #
#   Manages Python installations via pyenv and pip packages.                  #
#   Installs latest Python and essential development packages.                #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/package-manager-utils.zsh
source $MY/core/utils/ui-kit.zsh

# Ensure yq is installed
ensure_command_available "yq" "Install with: brew install yq"

################################################################################
# 🐍 PYTHON INSTALLATION VIA PYENV
################################################################################

# Check if pyenv is available
if ensure_command_available "pyenv" "" "false"; then
    # Get latest Python version from brew info
    LATEST_PYTHON_VERSION=$(brew info python | grep '(bottled)' | sed 's/==> python@3...: stable //g' | sed 's/ (bottled).*//g')

    if [[ -n "$LATEST_PYTHON_VERSION" ]]; then
        ui_info_simple "Installing Python $LATEST_PYTHON_VERSION..."
        pyenv install -s $LATEST_PYTHON_VERSION
        pyenv global $LATEST_PYTHON_VERSION
        ui_success_simple "Python $LATEST_PYTHON_VERSION installed and set as global"
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
    ui_info_simple "Upgrading pip..."
    pip install --upgrade pip
    ui_success_simple "pip upgraded"

    ui_spacer

    # Process pip packages using shared utilities
    ui_info_simple "Installing development packages..."
    process_package_configs "pip" "pip_install_package"
    ui_success_simple "Development packages installed"

    ui_spacer

    # Upgrade all installed packages
    ui_info_simple "Upgrading all installed packages..."
    pip-upgrade-all
    ui_success_simple "All packages upgraded"
fi

