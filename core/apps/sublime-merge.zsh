#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎨 SUBLIME MERGE CONFIGURATION                                             #
#   -----------------------------                                              #
#   Sets up Sublime Merge Git client with Meetio theme and JetBrains Mono    #
#   font for a beautiful and productive Git workflow experience.              #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh


################################################################################
# 📂 DIRECTORY SETUP
################################################################################

DIR="$HOME/Library/Application Support/Sublime Merge/Packages"

# Ensure directory exists
if [[ ! -d "$DIR" ]]; then
    mkdir -p "$DIR/User"
fi

################################################################################
# 🎨 THEME INSTALLATION & CONFIGURATION
################################################################################

if [[ ! -d "$DIR/Meetio Theme" ]]; then
    cd "$DIR" || return 1

    # Clone the theme repository
    git clone git@github.com:meetio-theme/merge-meetio-theme.git "Meetio Theme" 2>/dev/null

    # Create preferences configuration
    echo '{
  "font_face": "JetBrains Mono",
  "theme": "Merge Palenight.sublime-theme",
  "color_scheme": "Meetio Palenight.sublime-color-scheme",
}' > "User/Preferences.sublime-settings"

else
    cd "$DIR/Meetio Theme" || return 1
    git pull 2>/dev/null
fi

