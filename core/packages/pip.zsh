#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🐍 PYTHON PACKAGE MANAGER                                                  #
#   ------------------------                                                   #
#   Manages Python installations via pyenv and pip packages.                  #
#   Installs latest Python and essential development packages.                #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh


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


# Check if pip is available
if command -v pip >/dev/null 2>&1; then
    # Essential packages
    pip3install pip              # Ensure pip is up to date
    pip install pdf2docx         # PDF to DOCX converter utility

    # System maintenance
    pip install --upgrade pip    # Upgrade pip to latest version
    pip-upgrade-all             # Upgrade all installed packages

fi

################################################################################
# 🔧 PROFILE-SPECIFIC EXTENSIONS
################################################################################

# Load profile-specific pip configurations
source $MY/profiles/$OS_PROFILE/core/packages/pip.zsh 2>/dev/null

