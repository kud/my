#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔗 SYMBOLIC LINK MANAGER                                                   #
#   -----------------------                                                    #
#   Creates and manages symbolic links for configuration files and            #
#   directories based on YAML configuration.                                  #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh

# Display header
ui_spacer
ui_panel "Symbolic Link Setup" "Creating configuration symlinks" "info"
ui_spacer

check_sync_folder_exists() {
  [[ -n "$SYNC_FOLDER" ]]
}

expand_path_variables() {
  local path="$1"
  eval echo "$path"
}

create_single_symlink() {
  local name="$1"
  local source="$2"
  local target="$3"
  local description="$4"

  local expanded_source=$(expand_path_variables "$source")
  local expanded_target=$(expand_path_variables "$target")

  if ln -sfn "$expanded_source" "$expanded_target" 2>/dev/null; then
    ui_success_simple "$name: $description"
    ui_muted "  $expanded_target → $expanded_source"
  else
    ui_error_simple "Failed to create symlink: $name"
    ui_muted "  Source: $expanded_source"
    ui_muted "  Target: $expanded_target"
  fi
}

create_symlinks_from_config() {
  local config_file="$MY/config/system/symlinks.yml"
  
  ui_info_msg "Reading symlink configuration..."
  ui_muted "  Config: $config_file"
  ui_spacer

  if [[ ! -f "$config_file" ]]; then
    ui_error_msg "Configuration file not found"
    return 1
  fi

  local symlink_count=0
  yq eval '.symlinks | to_entries | .[] | .key + "|" + .value.source + "|" + .value.target + "|" + .value.description' "$config_file" | while IFS='|' read -r name source target description; do
    create_single_symlink "$name" "$source" "$target" "$description"
    ((symlink_count++))
  done
  
  ui_spacer
  ui_success_msg "Symlink creation complete"
}

main() {
  if ! check_sync_folder_exists; then
    ui_warning_msg "SYNC_FOLDER environment variable not set"
    ui_muted "  Some symlinks may fail without this variable"
    ui_muted "  Set it in your shell configuration to your sync directory"
    ui_spacer
  else
    ui_info_simple "Using sync folder: $SYNC_FOLDER"
    ui_spacer
  fi

  if ! check_yq_installed; then
    ui_error_msg "yq is required but not installed"
    ui_muted "  Install with: brew install yq"
    return 1
  fi

  create_symlinks_from_config
  
  ui_spacer
  ui_badge "success" " SYMLINKS CONFIGURED "
  ui_spacer
}

main