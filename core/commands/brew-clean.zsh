#!/usr/bin/env zsh

# Load helper functions and variables
source $MY/core/utils/helper.zsh

# Constants and Variables
LOG_FILE="$MY/logs/cleanup.log"
DRY_RUN=false  # Set to true for a dry-run mode
yaml_files=("$MY/config/packages.yml" "$MY/profiles/$OS_PROFILE/config/packages.yml")
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
        echo_fail "Homebrew is not installed. Exiting..."
    fi
    if ! command -v yq >/dev/null; then
        echo_fail "yq is not installed. Please install it with 'brew install yq'. Exiting..."
    fi
}

check_variables() {
    if [[ -z "$MY" || -z "$OS_PROFILE" ]]; then
        echo_fail "Environment variables 'MY' or 'OS_PROFILE' not set. Exiting..."
    fi
}

load_casks_from_files() {
    echo_task_start "Loading casks from YAML files"
    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            # Extract casks from brew.casks array in YAML
            local casks=$(yq eval '.brew.casks[]' "$yaml_file" 2>/dev/null)
            if [[ -n "$casks" ]]; then
                while IFS= read -r cask_name; do
                    if [[ -n "$cask_name" && "$cask_name" != "null" ]]; then
                        file_casks_map[$cask_name]=1
                    fi
                done <<< "$casks"
            fi
        else
            echo_warn "File '$yaml_file' is missing."
        fi
    done
    echo_task_done "Casks loaded from YAML"
}

check_installed_casks() {
    echo_task_start "Checking installed casks"
    installed_casks=$(brew list --cask)
    for cask in ${(f)installed_casks}; do
        installed_casks_map[$cask]=1
    done
    echo_task_done "Installed casks checked"
}

compare_casks() {
    echo_task_start "Comparing casks"
    local missing_casks=()
    for cask in ${(k)file_casks_map}; do
        if [[ -z "${installed_casks_map[$cask]}" ]]; then
            missing_casks+=($cask)
        fi
    done

    if [[ ${#missing_casks[@]} -gt 0 ]]; then
        echo_warn "Some casks are missing:"
        for cask in "${missing_casks[@]}"; do
            echo_subtle "$cask"
        done

        echo_space
        echo_info "Options for resolving missing casks:"
        echo "1) Install the missing casks"
        echo "2) Ignore for now"
        echo "3) Remove from configuration files"
        echo_input "Choose an option (1-3):"

        while true; do
            read choice
            case $choice in
                1)
                    echo_task_start "Installing missing casks"
                    for cask in "${missing_casks[@]}"; do
                        log_action "INSTALL: $cask"
                        $DRY_RUN && echo_subtle "[DRY-RUN] brew install --cask $cask" || brew install --cask "$cask"
                    done
                    echo_task_done "Missing casks installed"
                    break
                    ;;
                2)
                    log_action "IGNORE: Missing casks: ${missing_casks[*]}"
                    echo_warn "Missing casks ignored for now."
                    break
                    ;;
                3)
                    echo_task_start "Removing missing casks from configuration"
                    for cask in "${missing_casks[@]}"; do
                        for yaml_file in "${yaml_files[@]}"; do
                            if [[ -f "$yaml_file" ]]; then
                                # Check if the cask exists in this file
                                if yq eval ".brew.casks | contains([\"$cask\"])" "$yaml_file" 2>/dev/null | grep -q "true"; then
                                    # Remove the cask from the YAML file
                                    yq eval "del(.brew.casks[] | select(. == \"$cask\"))" -i "$yaml_file"
                                    log_action "REMOVE: $cask from $yaml_file"
                                    echo_info "$cask removed from $yaml_file"
                                fi
                            fi
                        done
                    done
                    echo_task_done "Missing casks removed from configuration"
                    break
                    ;;
                *)
                    echo_warn "Invalid input. Please choose 1, 2, or 3."
                    ;;
            esac
        done
    else
        echo_success "All casks are in order"
    fi
}

handle_discrepancies() {
    echo_task_start "Checking for discrepancies"
    echo_warn "If an app is listed below as a discrepancy, but should not be:"
    echo_warn "It may be installed as a cask but only tracked as a formula, or vice versa."
    echo_warn "Or, the name may have changed in Homebrew and needs to be cleaned up."
    echo_warn "Check both your config and your installed Homebrew casks/formulae."
    local casks_to_keep=()

    for cask in ${(k)installed_casks_map}; do
        if [[ -z "${file_casks_map[$cask]}" ]]; then
            echo_info "Discrepancy found: '$cask'"
            echo "1) Use 'soap'"
            echo "2) Uninstall"
            echo "3) Keep"
            echo_input "Please choose an option (1-3):"

            while true; do
                read choice
                case $choice in
                    1)
                        log_action "SOAP: $cask"
                        $DRY_RUN && echo_subtle "[DRY-RUN] soap $cask" || soap "$cask"
                        break
                        ;;
                    2)
                        log_action "UNINSTALL: $cask"
                        $DRY_RUN && echo_subtle "[DRY-RUN] brew uninstall $cask" || brew uninstall "$cask"
                        break
                        ;;
                    3)
                        log_action "KEEP: $cask"
                        casks_to_keep+=($cask)
                        break
                        ;;
                    *)
                        echo_warn "Invalid input. Please choose 1, 2, or 3."
                        ;;
                esac
            done
        fi
    done

    if [[ ${#casks_to_keep[@]} -gt 0 ]]; then
        echo_info "Kept casks:"
        for cask in "${casks_to_keep[@]}"; do
            echo_subtle "$cask"
        done
    else
        echo_success "No discrepancies found"
    fi
    echo_task_done "Discrepancy check complete"
}

# Main Script
check_dependencies
check_variables
echo_title "Starting Cleanup Process"
echo_space

load_casks_from_files
check_installed_casks
compare_casks
handle_discrepancies

echo_final_success
