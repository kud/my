#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 MIGRATION MANAGER                                                       #
#   -------------------                                                        #
#   Executes one-time migration scripts based on profile and tracks           #
#   completed migrations to avoid re-running.                                 #
#                                                                              #
################################################################################

source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh

MIGRATIONS_LOG="$MY/logs/migrations.log"
MIGRATIONS_DIR="$MY/migrations"
PROFILE="${OS_PROFILE:-default}"

################################################################################
# 📋 HELPER FUNCTIONS
################################################################################

ensure_migrations_log() {
    mkdir -p "$(dirname "$MIGRATIONS_LOG")"
    touch "$MIGRATIONS_LOG"
}

is_migration_completed() {
    local migration_id="$1"
    ensure_migrations_log
    grep -q "^${migration_id}$" "$MIGRATIONS_LOG"
}

mark_migration_completed() {
    local migration_id="$1"
    local migration_file="$2"
    ensure_migrations_log
    echo "$migration_id" >> "$MIGRATIONS_LOG"
    ui_success_simple "Migration $migration_id completed"
    
    # Auto-cleanup: delete the migration file after successful execution
    if [[ -f "$migration_file" ]]; then
        rm "$migration_file"
        ui_muted "  Cleaned up migration file (no longer needed)"
    fi
}

list_pending_migrations() {
    local context="$1" # "global" or profile name
    local migrations_path=""
    
    if [[ "$context" == "global" ]]; then
        migrations_path="$MIGRATIONS_DIR/global"
    else
        migrations_path="$MIGRATIONS_DIR/profiles/$context"
    fi
    
    [[ ! -d "$migrations_path" ]] && return
    
    for migration_file in "$migrations_path"/*.zsh(N); do
        local migration_id="${context}/$(basename "$migration_file" .zsh)"
        if ! is_migration_completed "$migration_id"; then
            echo "$migration_file|$migration_id"
        fi
    done
}

################################################################################
# 🚀 MAIN EXECUTION
################################################################################

count_pending_migrations() {
    local count=0
    while IFS='|' read -r migration_file migration_id; do
        ((count++))
    done < <(list_pending_migrations "global")
    while IFS='|' read -r migration_file migration_id; do
        ((count++))
    done < <(list_pending_migrations "$PROFILE")
    echo "$count"
}

run_migrations() {
    local force_mode=false
    local specific_migration=""
    local check_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                force_mode=true
                shift
                ;;
            --list)
                list_all_migrations
                return 0
                ;;
            --run)
                specific_migration="$2"
                shift 2
                ;;
            --check-only)
                check_only=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # If check-only, just return the count
    if $check_only; then
        count_pending_migrations
        return 0
    fi
    
    # Quick check: if nothing pending, skip all output
    local pending_count=$(count_pending_migrations)
    if [[ $pending_count -eq 0 ]]; then
        return 0
    fi
    
    ui_section "${UI_ICON_TOOLS} Running migrations"
    ui_info_simple "Profile: $PROFILE"
    ui_spacer
    
    local ran_any=false
    local total_ran=0
    
    # Run global migrations first
    ui_subsection "Global migrations"
    while IFS='|' read -r migration_file migration_id; do
        if [[ -n "$specific_migration" ]] && [[ "$migration_id" != *"$specific_migration"* ]]; then
            continue
        fi
        
        ui_info_simple "Running: $(basename "$migration_file" .zsh)"
        
        if source "$migration_file"; then
            mark_migration_completed "$migration_id" "$migration_file"
            ran_any=true
            ((total_ran++))
        else
            ui_error_simple "Migration failed: $migration_id"
            return 1
        fi
    done < <(list_pending_migrations "global")
    
    if ! $ran_any; then
        ui_success_simple "No pending global migrations"
    fi
    
    ui_spacer
    
    # Run profile-specific migrations
    ui_subsection "Profile-specific migrations ($PROFILE)"
    ran_any=false
    
    while IFS='|' read -r migration_file migration_id; do
        if [[ -n "$specific_migration" ]] && [[ "$migration_id" != *"$specific_migration"* ]]; then
            continue
        fi
        
        ui_info_simple "Running: $(basename "$migration_file" .zsh)"
        
        if source "$migration_file"; then
            mark_migration_completed "$migration_id" "$migration_file"
            ran_any=true
            ((total_ran++))
        else
            ui_error_simple "Migration failed: $migration_id"
            return 1
        fi
    done < <(list_pending_migrations "$PROFILE")
    
    if ! $ran_any; then
        ui_success_simple "No pending profile migrations"
    fi
    
    ui_spacer
    
    if [[ $total_ran -gt 0 ]]; then
        ui_success_simple "✓ Completed $total_ran migration(s)" 1
    else
        ui_success_simple "All migrations up to date" 1
    fi
}

list_all_migrations() {
    ui_section "${UI_ICON_SEARCH} Available migrations"
    
    ensure_migrations_log
    
    ui_subsection "Global migrations"
    if [[ -d "$MIGRATIONS_DIR/global" ]]; then
        for migration_file in "$MIGRATIONS_DIR/global"/*.zsh(N); do
            local migration_id="global/$(basename "$migration_file" .zsh)"
            if is_migration_completed "$migration_id"; then
                ui_success_simple "✓ $(basename "$migration_file" .zsh) (completed)"
            else
                ui_warning_simple "○ $(basename "$migration_file" .zsh) (pending)"
            fi
        done
    else
        ui_info_simple "No global migrations"
    fi
    
    ui_spacer
    ui_subsection "Profile migrations ($PROFILE)"
    if [[ -d "$MIGRATIONS_DIR/profiles/$PROFILE" ]]; then
        for migration_file in "$MIGRATIONS_DIR/profiles/$PROFILE"/*.zsh(N); do
            local migration_id="$PROFILE/$(basename "$migration_file" .zsh)"
            if is_migration_completed "$migration_id"; then
                ui_success_simple "✓ $(basename "$migration_file" .zsh) (completed)"
            else
                ui_warning_simple "○ $(basename "$migration_file" .zsh) (pending)"
            fi
        done
    else
        ui_info_simple "No profile-specific migrations"
    fi
}

# Run if executed directly
if [[ "${(%):-%x}" == "${0}" ]]; then
    run_migrations "$@"
fi
