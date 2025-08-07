#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔗 SYMLINK MANAGER                                                         #
#   -----------------                                                          #
#   Creates symbolic links for synchronized folders and application data.     #
#   Links Screenshots, espanso configs, and Rocket app data to sync folder.  #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

# Check if SYNC_FOLDER is set
if [[ -z "$SYNC_FOLDER" ]]; then
    :
fi

################################################################################
# 📸 SCREENSHOTS SYMLINK
################################################################################
ln -sfn "${SYNC_FOLDER}/Screenshots" ~/Screenshots 2>/dev/null

################################################################################
# 🔤 ESPANSO TEXT EXPANDER
################################################################################

ln -sfn "${SYNC_FOLDER}/Appdata/espanso/espanso" ~/Library/Application\ Support/espanso 2>/dev/null

################################################################################
# 🚀 ROCKET EMOJI PICKER
################################################################################


# Link preferences
ln -sfn "${SYNC_FOLDER}/Appdata/Rocket/net.matthewpalmer.Rocket.plist" ~/Library/Preferences/net.matthewpalmer.Rocket.plist 2>/dev/null

# Link application support
ln -sfn "${SYNC_FOLDER}/Appdata/Rocket/Rocket" ~/Library/Application\ Support/Rocket 2>/dev/null

################################################################################
# 🔄 CONFIGURATION RELOAD
################################################################################

source $HOME/.zshrc
