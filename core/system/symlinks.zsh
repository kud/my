#!/usr/bin/env zsh


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

  ln -sfn "$expanded_source" "$expanded_target" 2>/dev/null
}

create_symlinks_from_config() {
  local config_file="$MY/config/system/symlinks.yml"

  yq eval '.symlinks | to_entries | .[] | .key + "|" + .value.source + "|" + .value.target + "|" + .value.description' "$config_file" | while IFS='|' read -r name source target description; do
    create_single_symlink "$name" "$source" "$target" "$description"
  done
}

main() {
  if ! check_sync_folder_exists; then
    echo "Warning: SYNC_FOLDER environment variable not set - symlinks may fail"
  fi

  check_yq_installed || return 1

  create_symlinks_from_config
}

main
