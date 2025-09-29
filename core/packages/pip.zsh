#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🐍 PYTHON PACKAGE MANAGER (mise integrated)                                 #
#   ----------------------------------------                                    #
#   Relies solely on mise for Python runtime resolution.                       #
#   Does NOT pick 'latest' manually—version pinned in mise config.             #
#   Responsibilities here: ensure configured Python present, manage packages.  #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# Ensure yq (used by shared package helpers) is installed
ensure_command_available "yq" "Install with: brew install yq"

# Ensure mise available
if ! ensure_command_available "mise" "Install with: brew install mise" "false"; then
    ui_warning_simple "Skipping Python package setup (mise not installed)"
    return 0
fi

################################################################################
# 🧩 PYTHON RUNTIME VIA MISE
################################################################################
# Install the Python version declared in ~/.config/mise/config.toml if missing.
# We intentionally avoid auto-selecting newest to keep upgrades controlled
# (handled by core/packages/mise.zsh sync + version pin in config).

if ! mise current | grep -q '^python'; then
    ui_subsection "Installing configured Python via mise"
    if mise install python >/dev/null 2>&1; then
        ui_success_simple "Python installed (mise)" 1
    else
        ui_error_simple "Failed to install Python with mise"
        return 1
    fi
fi

# Use python -m pip to guarantee correct interpreter binding
if command -v python >/dev/null 2>&1; then
    PIP_RUN=(python -m pip)
else
    ui_error_simple "python not found after mise install"
    return 1
fi

################################################################################
# 📦 PIP PACKAGES & UPDATES
################################################################################

pip_install_package() {
    local package="$1"
    "${PIP_RUN[@]}" install "$package"
}

# Check if pip (via python -m pip) is functional
if "${PIP_RUN[@]}" --version >/dev/null 2>&1; then
    ui_subsection "Upgrading pip"
    "${PIP_RUN[@]}" install --upgrade pip >/dev/null 2>&1 && ui_success_simple "pip upgraded" 1 || ui_warning_simple "pip self-upgrade failed"

    ui_spacer

    ui_subsection "Installing development packages"
    process_package_configs "pip" "pip_install_package"
    ui_success_simple "Development packages installed" 1

    ui_spacer

    ui_subsection "Upgrading all installed packages"
    # Reuse existing helper if it expects 'pip' binary; temporarily mask if absent
    if command -v pip >/dev/null 2>&1; then
        pip-upgrade-all || ui_warning_simple "Bulk upgrade encountered errors"
    else
        # Fallback manual upgrade of outdated packages
        OUTDATED=$("${PIP_RUN[@]}" list --outdated --format=freeze | cut -d= -f1 || true)
        if [[ -n "$OUTDATED" ]]; then
            echo "$OUTDATED" | while read -r pkg; do
                [[ -n "$pkg" ]] && "${PIP_RUN[@]}" install --upgrade "$pkg" || true
            done
        fi
    fi
    ui_success_simple "All packages upgraded" 1
else
    ui_warning_simple "pip not available under mise-managed python"
fi

