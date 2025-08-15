#!/usr/bin/env zsh

# Source required utilities
source $MY/core/utils/package-manager-utils.zsh

# Constants and Variables
LOG_FILE="$MY/logs/cleanup.log"
DRY_RUN=false  # Set to true for a dry-run mode
yaml_files=("$(get_main_config_path brew)" "$(get_profile_config_path brew)")
declare -A file_casks_map
declare -A installed_casks_map

# Functions
log_action() {
    local log_dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir"
    fi

    echo "$(date): $1" >>"$LOG_FILE"
}

check_dependencies() {
    if ! command -v brew >/dev/null; then
        echo "Homebrew is not installed. Exiting..." >&2
        exit 1
    fi
    ensure_yq_installed
}

check_variables() {
    if [[ -z "$MY" || -z "$OS_PROFILE" ]]; then
        echo "Environment variables 'MY' or 'OS_PROFILE' not set. Exiting..." >&2
        exit 1
    fi
}

load_casks_from_files() {
    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            # Extract casks from packages.casks array in main config or casks array in profile config
            local casks=$(yq eval '.packages.casks[]?, .casks[]?' "$yaml_file" 2>/dev/null)
            if [[ -n "$casks" ]]; then
                while IFS= read -r cask_name; do
                    if [[ -n "$cask_name" && "$cask_name" != "null" ]]; then
                        file_casks_map[$cask_name]=1
                    fi
                done <<< "$casks"
            fi
        else
            echo "File '$yaml_file' is missing."
        fi
    done
}

check_installed_casks() {
    installed_casks=$(brew list --cask)
    for cask in ${(f)installed_casks}; do
        installed_casks_map[$cask]=1
    done
}

compare_casks() {
    local missing_casks=()
    for cask in ${(k)file_casks_map}; do
        if [[ -z "${installed_casks_map[$cask]}" ]]; then
            missing_casks+=($cask)
        fi
    done

    if [[ ${#missing_casks[@]} -gt 0 ]]; then
        echo "Some casks are missing:"
        for cask in "${missing_casks[@]}"; do
            echo "$cask"
        done

        echo
        echo "Options for resolving missing casks:"
        echo "1) Install the missing casks"
        echo "2) Ignore for now"
        echo "3) Remove from configuration files"
        echo "Choose an option (1-3):"

        while true; do
            read choice
            case $choice in
                1)
                    for cask in "${missing_casks[@]}"; do
                        log_action "INSTALL: $cask"
                        $DRY_RUN && echo "[DRY-RUN] brew install --cask $cask" || brew install --cask "$cask"
                    done
                    break
                    ;;
                2)
                    log_action "IGNORE: Missing casks: ${missing_casks[*]}"
                    echo "Missing casks ignored for now."
                    break
                    ;;
                3)
                    for cask in "${missing_casks[@]}"; do
                        for yaml_file in "${yaml_files[@]}"; do
                            if [[ -f "$yaml_file" ]]; then
                                # Check if the cask exists in this file
                                # Check if cask exists in packages.casks or casks array
                                if yq eval ".packages.casks | contains([\"$cask\"]) // (.casks | contains([\"$cask\"]) // false)" "$yaml_file" 2>/dev/null | grep -q "true"; then
                                    # Remove the cask from the YAML file (try both locations)
                                    yq eval "del(.packages.casks[] | select(. == \"$cask\")) | del(.casks[] | select(. == \"$cask\"))" -i "$yaml_file"
                                    log_action "REMOVE: $cask from $yaml_file"
                                    echo "$cask removed from $yaml_file"
                                fi
                            fi
                        done
                    done
                    break
                    ;;
                *)
                    echo "Invalid input. Please choose 1, 2, or 3."
                    ;;
            esac
        done
    else
        echo "All casks are in order"
    fi
}

handle_discrepancies() {
    echo "If an app is listed below as a discrepancy, but should not be:"
    echo "It may be installed as a cask but only tracked as a formula, or vice versa."
    echo "Or, the name may have changed in Homebrew and needs to be cleaned up."
    echo "Check both your config and your installed Homebrew casks/formulae."
    local casks_to_keep=()

    for cask in ${(k)installed_casks_map}; do
        if [[ -z "${file_casks_map[$cask]}" ]]; then
            echo "Discrepancy found: '$cask'"
            echo "1) Use 'soap'"
            echo "2) Uninstall"
            echo "3) Keep"
            echo "Please choose an option (1-3):"

            while true; do
                read choice
                case $choice in
                    1)
                        log_action "SOAP: $cask"
                        $DRY_RUN && echo "[DRY-RUN] soap $cask" || soap "$cask"
                        break
                        ;;
                    2)
                        log_action "UNINSTALL: $cask"
                        $DRY_RUN && echo "[DRY-RUN] brew uninstall $cask" || brew uninstall "$cask"
                        break
                        ;;
                    3)
                        log_action "KEEP: $cask"
                        casks_to_keep+=($cask)
                        break
                        ;;
                    *)
                        echo "Invalid input. Please choose 1, 2, or 3."
                        ;;
                esac
            done
        fi
    done

    if [[ ${#casks_to_keep[@]} -gt 0 ]]; then
        echo "Kept casks:"
        for cask in "${casks_to_keep[@]}"; do
            echo "$cask"
        done
    else
        echo "No discrepancies found"
    fi
}

# Main Script
check_dependencies
check_variables

load_casks_from_files
check_installed_casks
compare_casks
handle_discrepancies

