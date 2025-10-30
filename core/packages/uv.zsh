#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🐍 PYTHON DEV PACKAGES (uv-first)                                            #
#   --------------------------------                                            #
#   Minimal maintenance: ensure Python via mise, then install configured        #
#   development packages using `uv` if available, otherwise fall back to pip.   #
#   No mass upgrade loops, no pip self-upgrade churn.                           #
#                                                                              #
################################################################################

set -euo pipefail

source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# Ensure core tooling
ensure_command_available "yq" "Install with: brew install yq"
if ! ensure_command_available "mise" "Install with: brew install mise" "false"; then
  ui_warning_simple "Skipping Python packages (mise not installed)"
  return 0
fi

# Ensure configured Python runtime (uses version pin / config in mise)
if ! mise current | grep -q '^python'; then
  ui_subsection "Installing Python (mise)"
  if mise install python >/dev/null 2>&1; then
    ui_success_simple "Python installed" 1
  else
    ui_error_simple "Failed to install Python"
    return 1
  fi
fi

# Determine installer strategy
USE_UV=0
if command -v uv >/dev/null 2>&1; then
  USE_UV=1
fi

# Verify python still present
if ! command -v python >/dev/null 2>&1; then
  ui_error_simple "python not on PATH after install"
  return 1
fi

# Installer function for pip packages
python_install_package() {
  local package="$1"
  if (( USE_UV )); then
    if ! uv pip install --system "$package"; then
      ui_error_simple "Failed to install package '$package' with uv"
      return 1
    fi
  else
    if ! python -m pip install "$package"; then
      ui_error_simple "Failed to install package '$package' with pip"
      return 1
    fi
  fi
}

# Installer function for uv tools
python_install_tool() {
  local package="$1"
  if (( USE_UV )); then
    if ! uv tool install "$package"; then
      ui_error_simple "Failed to install tool '$package' with uv"
      return 1
    fi
  else
    ui_warning_simple "Skipping tool '$package' (uv not available)"
  fi
}

# Get config paths
main_config=$(get_main_config_path "uv")
profile_config=$(get_profile_config_path "uv")

# Install pip packages
ui_subsection "Installing pip packages ($([[ $USE_UV -eq 1 ]] && echo uv || echo pip))"
collect_packages_from_yaml "$main_config" "python_install_package" ".packages.pip[]"
collect_packages_from_yaml "$profile_config" "python_install_package" ".packages.pip[]"
ui_success_simple "Pip packages installed" 1

ui_spacer

# Install uv tools (uv creates ~/.local/bin automatically)
if (( USE_UV )); then
  ui_subsection "Installing uv tools"
  collect_packages_from_yaml "$main_config" "python_install_tool" ".packages.tool[]"
  collect_packages_from_yaml "$profile_config" "python_install_tool" ".packages.tool[]"
  ui_success_simple "Tools installed" 1
fi

ui_spacer
ui_success_simple "Python package maintenance complete" 1
