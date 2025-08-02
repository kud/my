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

echo_task_start "Creating application and data symlinks"
echo_space

# Check if SYNC_FOLDER is set
if [[ -z "$SYNC_FOLDER" ]]; then
    echo_warn "SYNC_FOLDER environment variable not set - some symlinks may fail"
fi

################################################################################
# 📸 SCREENSHOTS SYMLINK
################################################################################

echo_info "Linking Screenshots directory"
if ln -sfn "${SYNC_FOLDER}/Screenshots" ~/Screenshots 2>/dev/null; then
    echo_success "Screenshots directory symlinked successfully"
else
    echo_warn "Failed to create Screenshots symlink - check SYNC_FOLDER path"
fi

################################################################################
# 🔤 ESPANSO TEXT EXPANDER
################################################################################

echo_space
echo_info "Linking espanso text expander configuration"
if ln -sfn "${SYNC_FOLDER}/Appdata/espanso/espanso" ~/Library/Application\ Support/espanso 2>/dev/null; then
    echo_success "espanso configuration symlinked successfully"
else
    echo_warn "Failed to create espanso symlink - check if source exists"
fi

################################################################################
# 🚀 ROCKET EMOJI PICKER
################################################################################

echo_space
echo_info "Linking Rocket emoji picker configuration"

# Link preferences
if ln -sfn "${SYNC_FOLDER}/Appdata/Rocket/net.matthewpalmer.Rocket.plist" ~/Library/Preferences/net.matthewpalmer.Rocket.plist 2>/dev/null; then
    echo_success "Rocket preferences symlinked successfully"
else
    echo_warn "Failed to create Rocket preferences symlink"
fi

# Link application support
if ln -sfn "${SYNC_FOLDER}/Appdata/Rocket/Rocket" ~/Library/Application\ Support/Rocket 2>/dev/null; then
    echo_success "Rocket application data symlinked successfully"
else
    echo_warn "Failed to create Rocket app data symlink"
fi

################################################################################
# 🔄 CONFIGURATION RELOAD
################################################################################

echo_space
echo_info "Reloading shell configuration to apply changes"
source $HOME/.zshrc

echo_space
echo_task_done "Symlink creation completed"
echo_success "All application data is now synchronized! 🔗"
