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

# Header will be displayed by main.zsh

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

  # If target exists and is a directory (not a symlink), move it aside to avoid nesting
  if [[ -e "$expanded_target" && ! -L "$expanded_target" ]]; then
    # Detect already-correct case where directory's parent is same as we would link? Not reliable; always back up.
    local ts=$(date +%Y%m%d%H%M%S)
    local backup_path="${expanded_target}.backup.${ts}"
    if mv "$expanded_target" "$backup_path" 2>/dev/null; then
      ui_warning_simple "$name: existing path moved to backup"
      ui_muted "  Backup: $backup_path"
    else
      ui_error_simple "${name}: failed to move existing path (permission?)"
      ui_muted "  Target: $expanded_target"
      return 1
    fi
  fi

  # If target is an existing symlink pointing to desired source, skip
  if [[ -L "$expanded_target" ]]; then
    local current_link_target=$(readlink "$expanded_target")
    if [[ "$current_link_target" == "$expanded_source" ]]; then
      ui_success_simple "$name: already linked"
      ui_muted "  $expanded_target → $expanded_source"
      return 0
    fi
  fi

  if ln -sfn "$expanded_source" "$expanded_target" 2>/dev/null; then
    ui_success_simple "$name: $description"
    ui_muted "  $expanded_source → $expanded_target"
  else
    ui_error_simple "Failed to create symlink: $name"
    ui_muted "  Source: $expanded_source"
    ui_muted "  Target: $expanded_target"
  fi
}

create_symlinks_from_config() {
  local config_file="$MY/config/system/symlinks.yml"


  if [[ ! -f "$config_file" ]]; then
    ui_error_msg "Configuration file not found"
    return 1
  fi

  local symlink_count=0
  yq eval '.symlinks | to_entries | .[] | .key + "|" + .value.source + "|" + .value.target + "|" + .value.description' "$config_file" | while IFS='|' read -r name source target description; do
    create_single_symlink "$name" "$source" "$target" "$description"
    ((symlink_count++))
  done

}

main() {
  if ! check_sync_folder_exists; then
    ui_warning_msg "SYNC_FOLDER environment variable not set"
    ui_muted "  Some symlinks may fail without this variable"
    ui_muted "  Set it in your shell configuration to your sync directory"
    ui_spacer
  fi

  create_symlinks_from_config

  ui_spacer

  ui_success_simple "Symbolic links configured"
}

main
