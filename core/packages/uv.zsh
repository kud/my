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

# Installer function (abstract over uv/pip)
python_install_package() {
  local package="$1"
  if (( USE_UV )); then
    uv pip install "$package"
  else
    python -m pip install "$package"
  fi
}

ui_subsection "Installing development packages (${USE_UV:+uv}${USE_UV==0:pip})"
process_package_configs "python" "python_install_package"
ui_success_simple "Development packages installed" 1

ui_spacer
ui_success_simple "Python package maintenance complete" 1
