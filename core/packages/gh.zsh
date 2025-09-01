#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🐙 GITHUB CLI EXTENSIONS                                                   #
#   ------------------------                                                   #
#   Manages GitHub CLI extensions using a YAML config (profile-aware).        #
#   Installs listed extensions and upgrades them in a single batch.           #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh
source $MY/core/utils/ui-kit.zsh

# Ensure prerequisites
ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "gh" "Install with: brew install gh"

################################################################################
# 📦 EXTENSION INSTALLATION FUNCTIONS
################################################################################

gh_extension_install() {
  local ext="$1"
  [[ -z "$ext" ]] && return 0

  # Install extension (idempotent; gh will no-op if already installed)
  echo "  • $ext"
  ui_debug_command "gh extension install $ext"
  gh extension install "$ext" || true
}

gh_extension_upgrade_all() {
  ui_subsection "Upgrading GitHub CLI extensions"
  ui_debug_command "gh extension upgrade --all"
  gh extension upgrade --all || true
  ui_success_simple "Extensions upgraded" 1
}

################################################################################
# 🚀 MAIN
################################################################################

ui_subsection "Installing GitHub CLI extensions"
process_package_configs "gh" "gh_extension_install" "gh_extension_upgrade_all"
ui_success_simple "GitHub CLI extensions installed" 1
