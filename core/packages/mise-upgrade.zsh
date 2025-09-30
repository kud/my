#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   ⬆️  MISE FULL UPGRADE                                                       #
#   ---------------------                                                       #
#   Performs full runtime maintenance: install (ensure) + upgrade + prune.      #
#   Use this in heavier flows (e.g. `my update`).                               #
#                                                                              #
################################################################################

set -euo pipefail

source "$MY/core/utils/ui-kit.zsh"

if ! command -v mise >/dev/null 2>&1; then
  ui_error_simple "mise not installed (brew install mise)"
  exit 1
fi

ui_section "${UI_ICON_TOOLS} mise full upgrade"
ui_subsection "Resolved Active Tools (pre-upgrade)"
if ! mise current >/dev/null 2>&1; then
  ui_warning_simple "No active tools resolved (check mise config)."
else
  mise current
fi

ui_spacer
ui_subsection "Ensuring configured tools present"
if ! INSTALL_OUTPUT=$(mise install 2>&1); then
  ui_error_simple "Install step failed"
  echo "$INSTALL_OUTPUT"
else
  echo "$INSTALL_OUTPUT" | grep -v '^$' || true
  ui_success_simple "Configured tools installed/verified"
fi

ui_spacer
ui_subsection "Upgrading"
if ! UPGRADE_OUTPUT=$(mise upgrade 2>&1); then
  ui_error_simple "Upgrade failed"
  echo "$UPGRADE_OUTPUT"
else
  echo "$UPGRADE_OUTPUT" | grep -v '^$' || true
  ui_success_simple "Runtimes upgraded"
fi

ui_spacer
ui_subsection "Pruning"
if ! mise prune >/dev/null 2>&1; then
  ui_warning_simple "Prune failed"
else
  ui_success_simple "Unused versions pruned"
fi

ui_spacer
ui_subsection "Resolved Active Tools (post-upgrade)"
mise current || true

ui_spacer
ui_success_simple "mise full upgrade complete" 1
