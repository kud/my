#! /usr/bin/env zsh

source $MY/core/utils/ui-kit.zsh

if [ ! -d "$HOME/pCloud" ]; then
  mkdir -p ~/pCloud
  ui_info_simple "Opening pCloud installation page..."
  open "https://www.pcloud.com/how-to-install-pcloud-drive-mac-os.html?download=mac"
  read "?Install and configure pCloud and press [Enter] when finished..." </dev/tty
  ui_success_simple "pCloud setup completed"
else
  ui_success_simple "pCloud already configured"
fi
