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

# Ensure yq is installed
ensure_yq_installed

################################################################################
# 🐍 PYTHON INSTALLATION VIA PYENV
################################################################################

# Check if pyenv is available
if command -v pyenv >/dev/null 2>&1; then
    # Get latest Python version from brew info
    LATEST_PYTHON_VERSION=$(brew info python | grep '(bottled)' | sed 's/==> python@3...: stable //g' | sed 's/ (bottled).*//g')

    if [[ -n "$LATEST_PYTHON_VERSION" ]]; then
        pyenv install -s $LATEST_PYTHON_VERSION
        pyenv global $LATEST_PYTHON_VERSION
    fi
fi

################################################################################
# 📦 PIP PACKAGES & UPDATES
################################################################################

# Custom pip install function for use with shared utilities
pip_install_package() {
    local package="$1"
    pip install "$package"
}

# Check if pip is available
if command -v pip >/dev/null 2>&1; then
    # Upgrade pip itself first
    pip install --upgrade pip >/dev/null 2>&1

    # Process pip packages using shared utilities
    process_package_configs "pip" "pip_install_package"

    # Upgrade all installed packages
    pip-upgrade-all >/dev/null 2>&1
fi

