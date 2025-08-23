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
    fonts_synced=0
    
    # Operator Mono fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono" ]]; then
        if cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono"/* ~/Library/Fonts/ 2>/dev/null; then
            ui_success_simple "Synced Operator Mono to ~/Library/Fonts"
            ((fonts_synced++))
        fi
    fi

    # Operator Mono Lig fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig" ]]; then
        if cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig"/* ~/Library/Fonts/ 2>/dev/null; then
            ui_success_simple "Synced Operator Mono Lig to ~/Library/Fonts"
            ((fonts_synced++))
        fi
    fi
    
    if [[ $fonts_synced -eq 0 ]]; then
        ui_info_simple "No fonts to sync"
    fi
else
    ui_info_simple "No sync folder configured or fonts directory not found"
fi