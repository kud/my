#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📁 SYNC FILES MANAGER                                                      #
#   -------------------                                                        #
#   Copies files from synchronized storage (cloud/external) to local          #
#   system locations like fonts, configurations, and other resources.         #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up synchronized files"

################################################################################
# 🔤 FONTS
################################################################################

if [[ -n "${SYNC_FOLDER}" && -d "${SYNC_FOLDER}/Lib/fonts" ]]; then
    echo_info "Installing custom fonts from sync folder"
    
    # Operator Mono fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono" ]]; then
        cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono"/* ~/Library/Fonts/ 2>/dev/null
        echo_success "Operator Mono fonts installed"
    fi
    
    # Operator Mono Lig fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig" ]]; then
        cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig"/* ~/Library/Fonts/ 2>/dev/null
        echo_success "Operator Mono Lig fonts installed"
    fi
else
    echo_info "No sync folder available or fonts directory not found"
fi

################################################################################
# 📄 OTHER SYNC FILES
################################################################################
# Add other synchronized files here as needed
# Examples:
# - Configuration files
# - Templates
# - Scripts
# - Assets

echo_task_done "Synchronized files setup completed"