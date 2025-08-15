#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🩺 COMPREHENSIVE ENVIRONMENT HEALTH CHECKER                                #
#   ------------------------------------------                                 #
#   Performs extensive system health checks and diagnostics.                  #
#   Validates all aspects of the development environment.                     #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh

# Tracking variables
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
ERRORS=0
ISSUES=()

# Helper function for check results
record_check() {
    local check_status="$1"
    local message="$2"
    ((TOTAL_CHECKS++))
    
    case "$check_status" in
        "pass")
            ((PASSED_CHECKS++))
            ui_success_simple "$message"
            ;;
        "warn")
            ((WARNINGS++))
            ISSUES+=("⚠️  $message")
            ui_warning_simple "$message"
            ;;
        "error")
            ((ERRORS++))
            ISSUES+=("❌ $message")
            ui_error_simple "$message"
            ;;
    esac
}

ui_spacer
ui_primary "🩺 Environment Health Check"
ui_info_simple "Running comprehensive diagnostics..."
ui_spacer

################################################################################
# 🖥️ SYSTEM INFORMATION
################################################################################

ui_subtitle "System Information"

# Use fastfetch if available, fallback to manual detection
if command -v fastfetch >/dev/null 2>&1; then
    # Run fastfetch with minimal output
    fastfetch --logo none --structure "OS:Kernel:Uptime:Shell:CPU:Memory:Disk"
    record_check "pass" "System information retrieved"
else
    # Fallback to manual detection
    # macOS version
    if [[ -f /System/Library/CoreServices/SystemVersion.plist ]]; then
        macos_version=$(sw_vers -productVersion)
        ui_info_simple "macOS: $macos_version"
        
        # Check if macOS is recent (within 2 major versions)
        major_version=$(echo $macos_version | cut -d. -f1)
        if [[ $major_version -ge 13 ]]; then
            record_check "pass" "macOS version is current"
        else
            record_check "warn" "macOS version is outdated (consider upgrading)"
        fi
    else
        record_check "error" "Unable to detect macOS version"
    fi

    # Hardware architecture
    arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        ui_info_simple "Architecture: $arch (Apple Silicon)"
    elif [[ "$arch" == "x86_64" ]]; then
        ui_info_simple "Architecture: $arch (Intel)"
    else
        ui_info_simple "Architecture: $arch"
    fi

    # Shell version
    if [[ -n "$ZSH_VERSION" ]]; then
        ui_info_simple "Shell: zsh $ZSH_VERSION"
        record_check "pass" "Zsh shell detected"
    else
        record_check "warn" "Not running in zsh shell"
    fi
fi

ui_spacer

################################################################################
# 🍺 HOMEBREW HEALTH
################################################################################

ui_subtitle "Homebrew"

if command -v brew >/dev/null 2>&1; then
    # Check Homebrew installation
    brew_prefix=$(brew --prefix)
    ui_info_simple "Installation: $brew_prefix"
    
    # Check for Apple Silicon vs Intel
    arch=$(uname -m)
    if [[ "$arch" == "arm64" && "$brew_prefix" != "/opt/homebrew" ]]; then
        record_check "warn" "Homebrew not in optimal location for Apple Silicon"
    else
        record_check "pass" "Homebrew installation location is correct"
    fi
    
    ui_spacer
    ui_info_simple "Running brew doctor..."
    ui_spacer
    
    # Run brew doctor and display output directly
    brew_output=$(brew doctor 2>&1)
    brew_status=$?
    
    if [[ $brew_status -eq 0 ]]; then
        ui_success_simple "Your system is ready to brew."
        record_check "pass" "Homebrew is healthy"
    else
        # Display the brew doctor output directly
        echo "$brew_output"
        record_check "warn" "Homebrew has issues (see above)"
    fi
    
    ui_spacer
    
    # Check for outdated packages
    ui_info_simple "Checking for outdated packages..."
    outdated_list=$(brew outdated)
    outdated_count=$(echo "$outdated_list" | grep -c '^' 2>/dev/null || echo "0")
    
    if [[ $outdated_count -gt 0 && -n "$outdated_list" ]]; then
        record_check "warn" "$outdated_count Homebrew packages are outdated:"
        echo "$outdated_list" | while read -r package; do
            echo "  • $package"
        done
    else
        record_check "pass" "All Homebrew packages are up to date"
    fi
else
    record_check "error" "Homebrew not installed"
fi

ui_spacer

################################################################################
# 🛠️ DEVELOPMENT TOOLS
################################################################################

ui_subtitle "Development Tools"

# Essential tools with version checking
declare -A tools=(
    [git]="2.30.0"
    [node]="18.0.0"
    [npm]="8.0.0"
    [python3]="3.9.0"
    [ruby]="2.7.0"
)

for tool required_version in ${(kv)tools}; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        
        if [[ -n "$version" ]]; then
            record_check "pass" "$tool installed (v$version)"
        else
            record_check "pass" "$tool installed"
        fi
    else
        record_check "error" "$tool not installed"
    fi
done

ui_spacer

################################################################################
# 📦 PACKAGE MANAGERS
################################################################################

ui_subtitle "Package Managers"

# Node.js & npm
ui_info_simple "Node.js & npm:"
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    node_version=$(node --version 2>&1)
    npm_version=$(npm --version 2>&1)
    record_check "pass" "Node.js $node_version, npm v$npm_version"
    
    npm_prefix=$(npm config get prefix 2>/dev/null)
    if [[ -n "$npm_prefix" ]]; then
        ui_info_simple "  Global prefix: $npm_prefix"
        
        # Check if npm prefix is in PATH
        if echo "$PATH" | grep -q "$npm_prefix/bin"; then
            record_check "pass" "  npm bin directory in PATH"
        else
            record_check "warn" "  npm bin directory not in PATH"
        fi
    fi
    
    # Check global packages count
    global_packages=$(npm list -g --depth=0 2>/dev/null | grep -c '^[├└]' || echo "0")
    ui_info_simple "  Global packages: $global_packages installed"
    
    # Check cache size
    npm_cache=$(npm config get cache 2>/dev/null)
    if [[ -d "$npm_cache" ]]; then
        cache_size=$(du -sh "$npm_cache" 2>/dev/null | cut -f1)
        ui_info_simple "  Cache size: $cache_size"
    fi
else
    record_check "error" "Node.js or npm not installed"
fi

ui_spacer

# Python & pip
ui_info_simple "Python & pip:"
if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
    record_check "pass" "Python $python_version"
    
    if command -v pip3 >/dev/null 2>&1; then
        pip_version=$(pip3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        record_check "pass" "  pip v$pip_version"
        
        # Check pip packages count
        pip_packages=$(pip3 list 2>/dev/null | wc -l | tr -d ' ')
        pip_packages=$((pip_packages - 2))  # Subtract header lines
        ui_info_simple "  Installed packages: $pip_packages"
    else
        record_check "warn" "  pip3 not installed"
    fi
else
    record_check "error" "Python3 not installed"
fi

ui_spacer

# Ruby & RubyGems
ui_info_simple "Ruby & RubyGems:"
if command -v ruby >/dev/null 2>&1; then
    ruby_version=$(ruby --version 2>&1 | cut -d' ' -f2)
    record_check "pass" "Ruby $ruby_version"
    
    if command -v gem >/dev/null 2>&1; then
        gem_version=$(gem --version 2>&1)
        record_check "pass" "  RubyGems v$gem_version"
        
        # Check gem count
        gem_count=$(gem list 2>/dev/null | wc -l | tr -d ' ')
        ui_info_simple "  Installed gems: $gem_count"
    else
        record_check "warn" "  RubyGems not installed"
    fi
else
    record_check "error" "Ruby not installed"
fi

ui_spacer

################################################################################
# 🔧 MY ENVIRONMENT
################################################################################

ui_subtitle "My Environment"

# Check MY environment variable
if [[ -n "$MY" ]]; then
    ui_info_simple "Path: $MY"
    record_check "pass" "MY environment configured"
else
    record_check "error" "MY environment variable not set"
fi

# Check profile
if [[ -n "$OS_PROFILE" ]]; then
    ui_info_simple "Profile: $OS_PROFILE"
    record_check "pass" "Profile configured"
else
    ui_info_simple "Profile: default"
    record_check "pass" "Using default profile"
fi

ui_spacer


################################################################################
# 🌐 NETWORK & CONNECTIVITY
################################################################################

ui_subtitle "Network & Connectivity"

# Check network interface
ui_info_simple "Network interface status:"
if command -v ifconfig >/dev/null 2>&1; then
    active_interface=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
    if [[ -n "$active_interface" ]]; then
        interface_info=$(ifconfig "$active_interface" 2>/dev/null | grep "inet " | awk '{print $2}')
        if [[ -n "$interface_info" ]]; then
            record_check "pass" "Active interface $active_interface: $interface_info"
        else
            record_check "warn" "Interface $active_interface has no IP"
        fi
    else
        record_check "warn" "No active network interface found"
    fi
fi

# Check internet connectivity with timing
ui_info_simple "Testing internet connectivity:"
ping_result=$(ping -c 1 -t 2 github.com 2>&1)
ping_status=$?
if [[ $ping_status -eq 0 ]]; then
    ping_time=$(echo "$ping_result" | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/')
    record_check "pass" "Internet connection working (${ping_time}ms to github.com)"
else
    record_check "error" "No internet connection to github.com"
fi

# Test additional endpoints
ui_info_simple "Testing connectivity to common services:"
endpoints=("google.com" "cloudflare.com" "apple.com")
successful_endpoints=0

for endpoint in "${endpoints[@]}"; do
    if ping -c 1 -t 1 "$endpoint" >/dev/null 2>&1; then
        record_check "pass" "  $endpoint reachable"
        ((successful_endpoints++))
    else
        record_check "warn" "  $endpoint unreachable"
    fi
done

# Check DNS resolution with timing
ui_info_simple "Testing DNS resolution:"
if command -v dig >/dev/null 2>&1; then
    dns_result=$(dig +short +time=2 github.com 2>/dev/null)
    if [[ -n "$dns_result" ]]; then
        record_check "pass" "DNS resolution working (resolved to: $(echo $dns_result | head -1))"
    else
        record_check "warn" "DNS resolution slow or failing"
    fi
elif command -v nslookup >/dev/null 2>&1; then
    if nslookup github.com >/dev/null 2>&1; then
        record_check "pass" "DNS resolution working"
    else
        record_check "warn" "DNS resolution issues"
    fi
else
    record_check "warn" "No DNS tools available for testing"
fi

# Check DNS servers
dns_servers=$(scutil --dns 2>/dev/null | grep nameserver | awk '{print $3}' | sort -u | head -3)
if [[ -n "$dns_servers" ]]; then
    ui_info_simple "DNS servers: $(echo $dns_servers | tr '\n' ', ' | sed 's/, $//')"
fi

# Summary of connectivity
if [[ $successful_endpoints -eq ${#endpoints[@]} ]]; then
    record_check "pass" "All connectivity tests passed"
else
    record_check "warn" "$successful_endpoints/${#endpoints[@]} endpoint tests passed"
fi

ui_spacer

################################################################################
# 💾 DISK SPACE
################################################################################

ui_subtitle "Disk Space"

# Check available disk space
if command -v df >/dev/null 2>&1; then
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    available_space=$(df -h / | awk 'NR==2 {print $4}')
    
    ui_info_simple "Disk usage: ${disk_usage}% (${available_space} available)"
    
    if [[ $disk_usage -lt 80 ]]; then
        record_check "pass" "Sufficient disk space available"
    elif [[ $disk_usage -lt 90 ]]; then
        record_check "warn" "Disk space running low"
    else
        record_check "error" "Critical: Very low disk space"
    fi
fi

ui_spacer

################################################################################
# 🔒 SECURITY CHECKS
################################################################################

ui_subtitle "Security"

# Check for Xcode Command Line Tools
if xcode-select -p >/dev/null 2>&1; then
    xcode_path=$(xcode-select -p)
    record_check "pass" "Xcode Command Line Tools installed: $xcode_path"
else
    record_check "warn" "Xcode Command Line Tools not installed"
fi

# Check SIP status
if csrutil status | grep -q "enabled"; then
    record_check "pass" "System Integrity Protection enabled"
else
    record_check "warn" "System Integrity Protection disabled"
fi

# Check Gatekeeper status
if spctl --status | grep -q "enabled"; then
    record_check "pass" "Gatekeeper enabled"
else
    record_check "warn" "Gatekeeper disabled"
fi

ui_spacer

################################################################################
# 🔄 PATH ANALYSIS
################################################################################

ui_subtitle "PATH Configuration"

# Check for common PATH issues
path_dirs=(${(s/:/)PATH})
ui_info_simple "PATH has ${#path_dirs[@]} directories"

# Check for duplicates in PATH
unique_dirs=(${(u)path_dirs})
if [[ ${#path_dirs[@]} -ne ${#unique_dirs[@]} ]]; then
    dup_count=$((${#path_dirs[@]} - ${#unique_dirs[@]}))
    record_check "warn" "$dup_count duplicate entries in PATH"
else
    record_check "pass" "No duplicate PATH entries"
fi

# Check if important directories are in PATH
important_paths=(
    "/usr/local/bin"
    "$HOME/.local/bin"
    "$MY/bin"
)

for important_path in "${important_paths[@]}"; do
    if echo "$PATH" | grep -q "$important_path"; then
        record_check "pass" "$important_path in PATH"
    else
        if [[ -d "$important_path" ]]; then
            record_check "warn" "$important_path exists but not in PATH"
        fi
    fi
done

ui_spacer

################################################################################
# 📊 FINAL SUMMARY
################################################################################

ui_primary "📊 Health Check Summary"
ui_spacer

# Calculate health score
health_score=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))

# Display statistics
ui_info_simple "Total checks: $TOTAL_CHECKS"
ui_success_simple "Passed: $PASSED_CHECKS"
[[ $WARNINGS -gt 0 ]] && ui_warning_simple "Warnings: $WARNINGS"
[[ $ERRORS -gt 0 ]] && ui_error_simple "Errors: $ERRORS"

ui_spacer

# Health score visualization
if [[ $health_score -ge 90 ]]; then
    ui_success_msg "🎉 Excellent! System health: ${health_score}%"
elif [[ $health_score -ge 75 ]]; then
    ui_info_msg "👍 Good! System health: ${health_score}%"
elif [[ $health_score -ge 60 ]]; then
    ui_warning_msg "⚠️  Fair. System health: ${health_score}%"
else
    ui_error_msg "🚨 Poor! System health: ${health_score}%"
fi

# Show issues if any
if [[ ${#ISSUES[@]} -gt 0 ]]; then
    ui_spacer
    ui_subtitle "Issues Found"
    for issue in "${ISSUES[@]}"; do
        echo "  $issue"
    done
fi

# Recommendations
if [[ $ERRORS -gt 0 || $WARNINGS -gt 0 ]]; then
    ui_spacer
    ui_subtitle "Recommendations"
    
    [[ $ERRORS -gt 0 ]] && ui_info_simple "• Fix critical errors first (marked with ❌)"
    [[ $WARNINGS -gt 0 ]] && ui_info_simple "• Address warnings when possible (marked with ⚠️)"
    
    ui_spacer
    ui_info_simple "Run 'my doctor' again after making changes"
fi

ui_spacer