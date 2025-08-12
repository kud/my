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

# Check if yq is available for YAML parsing
if ! command -v yq >/dev/null 2>&1; then
    echo_info "Installing yq for YAML parsing"
    brew install yq
fi

PACKAGES_FILE="$MY/core/packages.yml"
PROFILE_PACKAGES_FILE="$MY/profiles/$OS_PROFILE/config/packages.yml"

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

collect_pip_packages_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local packages=$(yq eval '.pip.packages[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$packages" ]]; then
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                echo_info "Installing $package"
                pip install "$package"
            fi
        done <<< "$packages"
    fi
}

run_pip_post_install_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local post_install=$(yq eval '.pip.post_install[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$post_install" ]]; then
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command" >/dev/null 2>&1
            fi
        done <<< "$post_install"
    fi
}

echo_space
echo_info "Installing Python packages from YAML"

# Check if pip is available
if command -v pip >/dev/null 2>&1; then
    # Upgrade pip itself first
    echo_info "Upgrading pip to latest version"
    pip install --upgrade pip >/dev/null 2>&1

    # Collect all pip packages (base + profile)
    collect_pip_packages_from_yaml "$PACKAGES_FILE" "base configuration"
    collect_pip_packages_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

    # Upgrade all installed packages
    echo_info "Upgrading all installed pip packages"
    pip-upgrade-all >/dev/null 2>&1

    echo_space
    echo_title "Post-installation setup"
    run_pip_post_install_from_yaml "$PACKAGES_FILE" "base configuration"
    run_pip_post_install_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

    echo_success "Python packages installed and updated"
else
    echo_warn "pip not found - Python may not be properly installed"
fi

echo_space
echo_task_done "Python environment setup completed"
