#!/usr/bin/env zsh

# ################################################################################
#                                                                                #
#   🚀 SERVICES MANAGER                                                          #
#   -----------------                                                            #
#   Install/uninstall LaunchDaemons and LaunchAgents from services/ folder      #
#                                                                                #
# ################################################################################

set -euo pipefail

SERVICES_DIR="$MY/services"
LAUNCHD_DAEMON_DIR="/Library/LaunchDaemons"
LAUNCHD_AGENT_DIR="/Library/LaunchAgents"

usage() {
    cat << EOF
Usage: my services [subcommand]

Manage system services with macOS' launchctl daemon manager.

Operates on /Library/LaunchDaemons (started at boot).

my services [list]:
    List information about all managed services.

my services start (service|--all):
    Start the service immediately and register it to launch at boot.

my services stop (service|--all):
    Stop the service immediately and unregister it from launching at boot.

my services restart (service|--all):
    Stop (if necessary) and start the service immediately and register it to
    launch at boot.

my services info (service|--all):
    List detailed information about managed service(s).

Available services:
EOF

    # Dynamically list available services
    local found=false
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        found=true
        local name=$(basename "$plist" .plist)
        echo "    $name"
    done
    if [ "$found" = false ]; then
        echo "    (no services found)"
    fi

    cat << EOF

Examples:
    my services list                    # List all services
EOF

    # Dynamic example with first available service
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        local name=$(basename "$plist" .plist)
        echo "    my services start $name         # Start specific service"
        echo "    my services info $name          # Get service info"
        break
    done

    echo "    my services start --all             # Start all services"
}

list_services() {
    local found=false

    # Check if we have any services
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        found=true
        break
    done

    if [ "$found" = false ]; then
        echo "No services found in $SERVICES_DIR"
        return
    fi

    # Print header
    printf "\033[1m%-20s %-10s %-10s %s\033[0m\n" "Name" "Status" "User" "File"

    # Print services
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        local name=$(basename "$plist" .plist)
        local target_file="$LAUNCHD_DAEMON_DIR/${name}.plist"
        local service_status="none"
        local user=""
        local file=""

        if [[ -f "$target_file" ]]; then
            # Check if loaded
            if sudo launchctl list | grep -q "$name" 2>/dev/null; then
                service_status="started"
                user="root"
                file="$target_file"
            else
                service_status="stopped"
                user="root"
                file="$target_file"
            fi
        fi

        printf "%-20s %-10s %-10s %s\n" "$name" "$service_status" "$user" "$file"
    done
}

install_service() {
    local service="$1"
    local plist_file="$SERVICES_DIR/${service}.plist"
    local target_file="$LAUNCHD_DAEMON_DIR/${service}.plist"

    if [[ ! -f "$plist_file" ]]; then
        echo "❌ Service '$service' not found in $SERVICES_DIR"
        return 1
    fi

    # Check if already installed and running
    if [[ -f "$target_file" ]] && sudo launchctl list | grep -q "$service" 2>/dev/null; then
        echo "✅ $service already running"
        return 0
    fi

    echo "📦 Installing $service..."

    # Copy plist to LaunchDaemons
    sudo cp "$plist_file" "$target_file"

    # Fix permissions
    sudo chown root:wheel "$target_file"
    sudo chmod 644 "$target_file"

    # Load the service
    sudo launchctl load -w "$target_file"

    echo "✅ $service installed and loaded"
}

uninstall_service() {
    local service="$1"
    local target_file="$LAUNCHD_DAEMON_DIR/${service}.plist"

    if [[ ! -f "$target_file" ]]; then
        echo "⚠️  Service '$service' not installed"
        return 1
    fi

    echo "🗑️  Uninstalling $service..."

    # Unload the service
    sudo launchctl unload -w "$target_file" 2>/dev/null || true

    # Remove plist
    sudo rm -f "$target_file"

    echo "✅ $service uninstalled"
}

status_service() {
    local service="$1"
    local target_file="$LAUNCHD_DAEMON_DIR/${service}.plist"

    if [[ ! -f "$target_file" ]]; then
        echo "❌ $service: Not installed"
        return 1
    fi

    # Check if loaded
    if sudo launchctl list | grep -q "$service"; then
        echo "✅ $service: Installed and loaded"
    else
        echo "⚠️  $service: Installed but not loaded"
    fi
}

reload_service() {
    local service="$1"
    local target_file="$LAUNCHD_DAEMON_DIR/${service}.plist"

    if [[ ! -f "$target_file" ]]; then
        echo "❌ Service '$service' not installed"
        return 1
    fi

    echo "🔄 Reloading $service..."

    # Unload and reload
    sudo launchctl unload -w "$target_file" 2>/dev/null || true
    sudo launchctl load -w "$target_file"

    echo "✅ $service reloaded"
}

install_all() {
    echo "📦 Installing all services..."
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        local service=$(basename "$plist" .plist)
        install_service "$service"
    done
}

uninstall_all() {
    echo "🗑️  Uninstalling all services..."
    for plist in "$LAUNCHD_DAEMON_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        local service=$(basename "$plist" .plist)
        # Only uninstall if we have the source in our services dir
        if [[ -f "$SERVICES_DIR/${service}.plist" ]]; then
            uninstall_service "$service"
        fi
    done
}

status_all() {
    echo "📊 Service status:"
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        local service=$(basename "$plist" .plist)
        status_service "$service"
    done
}

reload_all() {
    echo "🔄 Reloading all services..."
    for plist in "$SERVICES_DIR"/*.plist; do
        [ -f "$plist" ] || continue
        local service=$(basename "$plist" .plist)
        reload_service "$service"
    done
}

# Main command handling
case "${1:-list}" in
    start)
        if [[ "${2:-}" == "--all" ]]; then
            install_all
        elif [[ -n "${2:-}" ]]; then
            install_service "$2"
        else
            echo "Error: 'start' requires a service name or --all"
            usage
            exit 1
        fi
        ;;
    stop)
        if [[ "${2:-}" == "--all" ]]; then
            uninstall_all
        elif [[ -n "${2:-}" ]]; then
            uninstall_service "$2"
        else
            echo "Error: 'stop' requires a service name or --all"
            usage
            exit 1
        fi
        ;;
    restart)
        if [[ "${2:-}" == "--all" ]]; then
            reload_all
        elif [[ -n "${2:-}" ]]; then
            reload_service "$2"
        else
            echo "Error: 'restart' requires a service name or --all"
            usage
            exit 1
        fi
        ;;
    list)
        list_services
        ;;
    info)
        if [[ "${2:-}" == "--all" ]]; then
            status_all
        elif [[ -n "${2:-}" ]]; then
            status_service "$2"
        else
            status_all
        fi
        ;;
    # Legacy compatibility (can be removed later)
    install)
        if [[ -n "${2:-}" ]]; then
            install_service "$2"
        else
            install_all
        fi
        ;;
    uninstall)
        if [[ -n "${2:-}" ]]; then
            uninstall_service "$2"
        else
            uninstall_all
        fi
        ;;
    status)
        if [[ -n "${2:-}" ]]; then
            status_service "$2"
        else
            status_all
        fi
        ;;
    reload)
        if [[ -n "${2:-}" ]]; then
            reload_service "$2"
        else
            reload_all
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac
