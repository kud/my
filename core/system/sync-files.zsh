#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📁 SYNC FILES MANAGER                                                      #
#   -------------------                                                        #
#   Copies files from synchronized storage (cloud/external) to local          #
#   system locations like fonts, configurations, and other resources.         #
#                                                                              #
################################################################################

source $MY/core/utils/ui-kit.zsh

################################################################################
# 🔤 FONTS
################################################################################

if [[ -n "${SYNC_FOLDER}" && -d "${SYNC_FOLDER}/Lib/fonts" ]]; then
    fonts_synced=()
    # Operator Mono fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono" ]]; then
        cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono"/* ~/Library/Fonts/ 2>/dev/null && fonts_synced+=("Operator Mono")
    fi

    # Operator Mono Lig fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig" ]]; then
        cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig"/* ~/Library/Fonts/ 2>/dev/null && fonts_synced+=("Operator Mono Lig")
    fi
    
    if [[ ${#fonts_synced[@]} -gt 0 ]]; then
        ui_success_simple "Synced ${(j:, :)fonts_synced} to ~/Library/Fonts"
    else
        ui_info_simple "No fonts to sync"
    fi
else
    ui_info_simple "No sync folder configured or fonts directory not found"
fi

