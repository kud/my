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
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh


# Check if yq is available for YAML parsing
if ! command -v yq >/dev/null 2>&1; then
    brew install yq
fi

PACKAGES_FILE="$MY/config/packages/pip.yml"
PROFILE_PACKAGES_FILE="$MY/profiles/$OS_PROFILE/config/packages/pip.yml"

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

collect_pip_packages_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local packages=$(yq eval '.packages[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$packages" ]]; then
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
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

    local post_install=$(yq eval '.post_install[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$post_install" ]]; then
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command" >/dev/null 2>&1
            fi
        done <<< "$post_install"
    fi
}


# Check if pip is available
if command -v pip >/dev/null 2>&1; then
    # Upgrade pip itself first
    pip install --upgrade pip >/dev/null 2>&1

    # Collect all pip packages (base + profile)
    collect_pip_packages_from_yaml "$PACKAGES_FILE" "base configuration"
    collect_pip_packages_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

    # Upgrade all installed packages
    pip-upgrade-all >/dev/null 2>&1

    run_pip_post_install_from_yaml "$PACKAGES_FILE" "base configuration"
    run_pip_post_install_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

fi

