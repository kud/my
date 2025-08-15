#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 ABBREVIATIONS MANAGER                                                   #
#   ---------------------                                                      #
#   Dynamically manages shell abbreviations from config/cli/abbr.yml          #
#                                                                              #
################################################################################

source ~/.zshrc
source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

config_file="$MY/config/cli/abbr.yml"


# Only load if abbr command is available
if ! ensure_command_available "abbr" "" "false"; then
  return 1
fi

# Check if yq is available
if ! ensure_command_available "yq" "Install with: brew install yq" "false"; then
  return 1
fi

# Get current abbreviations and erase them all (silently)
for abbr_name in $(abbr list-abbreviations 2>/dev/null); do
    abbr erase "$abbr_name" >/dev/null 2>&1
done

# Read all abbreviations from YAML and apply them
abbreviations_created=()
yq eval '.abbreviations | to_entries | .[] | .key + "=" + .value' "$config_file" | while read setting; do
    key=$(echo $setting | cut -d'=' -f1)
    value=$(echo $setting | cut -d'=' -f2-)
    if abbr "$key"="$value" >/dev/null 2>&1; then
        abbreviations_created+=("$key")
    fi
done

# Show the abbreviations that were created
if [[ ${#abbreviations_created[@]} -gt 0 ]]; then
    ui_success_simple "Created ${#abbreviations_created[@]} shell abbreviations: ${abbreviations_created[*]}"
else
    ui_info_simple "No abbreviations to create"
fi
