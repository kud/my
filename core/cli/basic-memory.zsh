#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧠 BASIC MEMORY CONFIGURATOR                                               #
#   -----------------------------                                              #
#   Configures Basic Memory CLI with projects from config/cli/basic-memory.yml#
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh
source $MY/shell/globals.zsh

# Handle show-config subcommand
if [[ "$1" == "show-config" ]]; then
    ui_subtitle "Basic Memory Config:"

    config_file="$HOME/.config/basic-memory/config.toml"

    if [[ -f "$config_file" ]]; then
        ui_info_simple "$config_file" 0
    else
        ui_warning_simple "$config_file (not found)" 0
    fi
    ui_spacer
    return 0
fi

ui_subsection "Configuring Basic Memory"

# Define basic-memory command path
BASIC_MEMORY_CMD="$HOME/.local/bin/basic-memory"

# Check if Basic Memory is installed
if [[ ! -x "$BASIC_MEMORY_CMD" ]]; then
    ui_error_msg "Basic Memory CLI not found at $BASIC_MEMORY_CMD" 1
    ui_error_msg "Install via: uv tool install basic-memory" 1
    return 1
fi

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    ui_error_msg "yq not found. Install with: brew install yq" 1
    return 1
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/basic-memory.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/basic-memory.yml"

# Function to expand environment variables in a string
expand_env_vars() {
    local text="$1"
    eval echo "$text"
}

# Function to add a project
add_project() {
    local name="$1"
    local path="$2"
    local is_default="$3"

    # Expand environment variables in path
    path=$(expand_env_vars "$path")

    # Check if project already exists at the correct path
    local list_output
    list_output=$("$BASIC_MEMORY_CMD" project list 2>&1)

    # Check if project exists
    if [[ "$list_output" =~ "│ $name" ]]; then
        # Project exists - extract current path from the line
        # The output format is: │ name │ path │ default │
        local project_line
        while IFS= read -r line; do
            if [[ "$line" =~ "│ $name" ]]; then
                project_line="$line"
                break
            fi
        done <<< "$list_output"

        # Extract the path (3rd column between │ separators)
        local current_path="${project_line#*│}"      # Remove first column
        current_path="${current_path#*│}"            # Remove second column (name)
        current_path="${current_path%%│*}"           # Keep only third column (path)
        current_path="${current_path## }"            # Trim leading spaces
        current_path="${current_path%% }"            # Trim trailing spaces

        # Expand ~ in current_path for comparison
        current_path="${current_path/#\~/$HOME}"

        if [[ "$current_path" == "$path" ]]; then
            ui_info_simple "Project '$name' already at correct path" 0
        else
            ui_info_simple "Project '$name' exists at different path, updating..." 0

            # Move project to new location
            local move_output
            move_output=$("$BASIC_MEMORY_CMD" project move "$name" "$path" 2>&1)
            local move_exit=$?

            if [[ $move_exit -eq 0 ]]; then
                ui_success_simple "Updated project: $name -> $path" 0
            else
                ui_error_msg "Failed to move project: $name" 0
                if [[ -n "$move_output" ]]; then
                    ui_error_msg "  $move_output" 0
                fi
                return 1
            fi
        fi
    else
        # Project doesn't exist, add it
        local output
        output=$("$BASIC_MEMORY_CMD" project add "$name" "$path" 2>&1)
        local exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            ui_success_simple "Added project: $name -> $path" 0
        else
            ui_error_msg "Failed to add project: $name" 0
            if [[ -n "$output" ]]; then
                ui_error_msg "  $output" 0
            fi
            return 1
        fi
    fi

    # Set as default if needed
    if [[ "$is_default" == "true" ]]; then
        # Check if already default (has ✓ in the line)
        if ! [[ "$list_output" =~ "│ $name".*"✓" ]]; then
            "$BASIC_MEMORY_CMD" project default "$name" >/dev/null 2>&1
            ui_success_simple "Set '$name' as default project" 0
        fi
    fi
}

# Process common projects (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
    project_names=($(yq -r '.projects | keys[]' "$COMMON_CONFIG" 2>/dev/null))

    for name in "${project_names[@]}"; do
        path=$(yq -r ".projects.$name.path" "$COMMON_CONFIG" 2>/dev/null)
        is_default=$(yq -r ".projects.$name.default // false" "$COMMON_CONFIG" 2>/dev/null)

        if [[ -n "$path" ]]; then
            add_project "$name" "$path" "$is_default"
        fi
    done
fi

# Process profile-specific projects (if config exists)
if [[ -f "$PROFILE_CONFIG" ]]; then
    project_names=($(yq -r '.projects | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${project_names[@]}"; do
        path=$(yq -r ".projects.$name.path" "$PROFILE_CONFIG" 2>/dev/null)
        is_default=$(yq -r ".projects.$name.default // false" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ -n "$path" ]]; then
            add_project "$name" "$path" "$is_default"
        fi
    done
fi

ui_success_simple "Basic Memory configuration complete" 1
