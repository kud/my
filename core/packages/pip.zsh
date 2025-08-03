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

echo_task_start "Setting up Python environment"

################################################################################
# 🐍 PYTHON INSTALLATION VIA PYENV
################################################################################

echo_info "Installing latest Python version via pyenv"

# Check if pyenv is available
if command -v pyenv >/dev/null 2>&1; then
    # Get latest Python version from brew info
    LATEST_PYTHON_VERSION=$(brew info python | grep '(bottled)' | sed 's/==> python@3...: stable //g' | sed 's/ (bottled).*//g')

    if [[ -n "$LATEST_PYTHON_VERSION" ]]; then
        echo_info "Installing Python $LATEST_PYTHON_VERSION"
        pyenv install -s $LATEST_PYTHON_VERSION
        pyenv global $LATEST_PYTHON_VERSION
        echo_success "Python $LATEST_PYTHON_VERSION set as global version"
    else
        echo_warn "Could not determine latest Python version"
    fi
else
    echo_warn "pyenv not found - install via Homebrew if needed"
fi

################################################################################
# 📦 PIP PACKAGES & UPDATES
################################################################################

echo_space
echo_info "Installing and updating Python packages"

# Check if pip is available
if command -v pip >/dev/null 2>&1; then
    # Essential packages
    pip3install pip              # Ensure pip is up to date
    pip install pdf2docx         # PDF to DOCX converter utility

    # System maintenance
    pip install --upgrade pip    # Upgrade pip to latest version
    pip-upgrade-all             # Upgrade all installed packages

    echo_success "Python packages installed and updated"
else
    echo_warn "pip not found - Python may not be properly installed"
fi

################################################################################
# 🔧 PROFILE-SPECIFIC EXTENSIONS
################################################################################

# Load profile-specific pip configurations
source $MY/profiles/$OS_PROFILE/core/packages/pip.zsh 2>/dev/null

echo_space
echo_task_done "Python environment setup completed"
echo_success "Python development environment is ready! 🐍"
