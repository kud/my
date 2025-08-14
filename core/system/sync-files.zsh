#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📁 SYNC FILES MANAGER                                                      #
#   -------------------                                                        #
#   Copies files from synchronized storage (cloud/external) to local          #
#   system locations like fonts, configurations, and other resources.         #
#                                                                              #
################################################################################


################################################################################
# 🔤 FONTS
################################################################################

if [[ -n "${SYNC_FOLDER}" && -d "${SYNC_FOLDER}/Lib/fonts" ]]; then
    # Operator Mono fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono" ]]; then
        cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono"/* ~/Library/Fonts/ 2>/dev/null
    fi

    # Operator Mono Lig fonts
    if [[ -d "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig" ]]; then
        cp "${SYNC_FOLDER}/Lib/fonts/Operator Mono Lig"/* ~/Library/Fonts/ 2>/dev/null
    fi
fi

