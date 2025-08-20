#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎨 MODERN ZSH UI KIT                                                       #
#   ------------------                                                         #
#   A comprehensive collection of modern UI components for creating beautiful  #
#   and interactive Zsh scripts. Includes colors, icons, layouts, animations, #
#   progress indicators, and interactive elements.                             #
#                                                                              #
################################################################################

# Terminal capabilities detection
autoload colors
if [[ "$terminfo[colors]" -gt 8 ]]; then
    colors
fi

# Check for modern terminal features
_UI_SUPPORTS_256_COLORS=$(tput colors 2>/dev/null || echo 8)
_UI_SUPPORTS_UNICODE=true
_UI_TERMINAL_WIDTH=$(tput cols 2>/dev/null || echo 80)
_UI_TERMINAL_HEIGHT=$(tput lines 2>/dev/null || echo 24)

################################################################################
# 🌈 EXTENDED COLOR PALETTE
################################################################################

# Basic colors (compatible with all terminals)
export UI_BLACK='\033[0;30m'
export UI_RED='\033[0;31m'
export UI_GREEN='\033[0;32m'
export UI_YELLOW='\033[0;33m'
export UI_BLUE='\033[0;34m'
export UI_MAGENTA='\033[0;35m'
export UI_CYAN='\033[0;36m'
export UI_WHITE='\033[0;37m'

# Bright colors
export UI_BRIGHT_BLACK='\033[0;90m'
export UI_BRIGHT_RED='\033[0;91m'
export UI_BRIGHT_GREEN='\033[0;92m'
export UI_BRIGHT_YELLOW='\033[0;93m'
export UI_BRIGHT_BLUE='\033[0;94m'
export UI_BRIGHT_MAGENTA='\033[0;95m'
export UI_BRIGHT_CYAN='\033[0;96m'
export UI_BRIGHT_WHITE='\033[0;97m'

# Bold colors
export UI_BOLD_BLACK='\033[1;30m'
export UI_BOLD_RED='\033[1;31m'
export UI_BOLD_GREEN='\033[1;32m'
export UI_BOLD_YELLOW='\033[1;33m'
export UI_BOLD_BLUE='\033[1;34m'
export UI_BOLD_MAGENTA='\033[1;35m'
export UI_BOLD_CYAN='\033[1;36m'
export UI_BOLD_WHITE='\033[1;37m'

# Background colors
export UI_BG_BLACK='\033[40m'
export UI_BG_RED='\033[41m'
export UI_BG_GREEN='\033[42m'
export UI_BG_YELLOW='\033[43m'
export UI_BG_BLUE='\033[44m'
export UI_BG_MAGENTA='\033[45m'
export UI_BG_CYAN='\033[46m'
export UI_BG_WHITE='\033[47m'

# Reset and special
export UI_RESET='\033[0m'
export UI_BOLD='\033[1m'
export UI_DIM='\033[2m'
export UI_ITALIC='\033[3m'
export UI_UNDERLINE='\033[4m'
export UI_BLINK='\033[5m'
export UI_REVERSE='\033[7m'
export UI_STRIKETHROUGH='\033[9m'

# Modern semantic colors (256-color mode)
if [[ $_UI_SUPPORTS_256_COLORS -ge 256 ]]; then
    export UI_PRIMARY='\033[38;5;226m'     # Bright yellow
    export UI_SECONDARY='\033[38;5;8m'     # Gray
    export UI_SUCCESS='\033[38;5;46m'      # Bright green
    export UI_WARNING='\033[38;5;208m'     # Orange
    export UI_DANGER='\033[38;5;196m'      # Bright red
    export UI_INFO='\033[38;5;39m'         # Blue
    export UI_MUTED='\033[38;5;244m'       # Light gray
    export UI_ACCENT='\033[38;5;226m'      # Bright yellow
else
    # Fallback for 16-color terminals
    export UI_PRIMARY=$UI_YELLOW
    export UI_SECONDARY=$UI_BRIGHT_BLACK
    export UI_SUCCESS=$UI_GREEN
    export UI_WARNING=$UI_YELLOW
    export UI_DANGER=$UI_RED
    export UI_INFO=$UI_BLUE
    export UI_MUTED=$UI_BRIGHT_BLACK
    export UI_ACCENT=$UI_YELLOW
fi

################################################################################
# 📱 MODERN ICONS & SYMBOLS
################################################################################

# Status icons (emoji style)
export UI_ICON_SUCCESS="✅"
export UI_ICON_ERROR="❌"
export UI_ICON_WARNING="⚠️"
export UI_ICON_INFO="ℹ️"
export UI_ICON_QUESTION="❓"

# Alternative simple icons
export UI_ICON_CHECKMARK="✓"
export UI_ICON_CROSS="✗"
export UI_ICON_CHECK_ALT="✔"
export UI_ICON_CROSS_ALT="✗"
export UI_ICON_STARTER="❯"
export UI_ICON_INFO_BRACKET="[i]"
export UI_ICON_USER_BRACKET="[?]"
export UI_ICON_WARN_BRACKET="[!]"
export UI_ICON_INPUT_BRACKET="[>]"

# Navigation
export UI_ICON_ARROW_RIGHT="→"
export UI_ICON_ARROW_LEFT="←"
export UI_ICON_ARROW_UP="↑"
export UI_ICON_ARROW_DOWN="↓"

# Action icons
export UI_ICON_DOWNLOAD="⬇️ "
export UI_ICON_UPLOAD="⬆️ "
export UI_ICON_INSTALL="📦"
export UI_ICON_DELETE="🗑️ "
export UI_ICON_EDIT="✏️ "
export UI_ICON_SEARCH="🔍"
export UI_ICON_SETTINGS="⚙️ "
export UI_ICON_REFRESH="🔄"
export UI_ICON_LOCK="🔒"
export UI_ICON_UNLOCK="🔓"

# Progress & loading
export UI_ICON_LOADING="⏳"
export UI_ICON_CLOCK="🕐"
export UI_ICON_ROCKET="🚀"
export UI_ICON_FIRE="🔥"
export UI_ICON_STAR="⭐"
export UI_ICON_HEART="❤️ "
export UI_ICON_THUMBS_UP="👍"

# Geometric shapes
export UI_ICON_CIRCLE="●"
export UI_ICON_CIRCLE_EMPTY="○"
export UI_ICON_SQUARE="■"
export UI_ICON_SQUARE_EMPTY="□"
export UI_ICON_TRIANGLE="▲"
export UI_ICON_DIAMOND="◆"

# Box drawing characters
export UI_BOX_HORIZONTAL="─"
export UI_BOX_VERTICAL="│"
export UI_BOX_TOP_LEFT="┌"
export UI_BOX_TOP_RIGHT="┐"
export UI_BOX_BOTTOM_LEFT="└"
export UI_BOX_BOTTOM_RIGHT="┘"
export UI_BOX_CROSS="┼"
export UI_BOX_T_DOWN="┬"
export UI_BOX_T_UP="┴"
export UI_BOX_T_RIGHT="├"
export UI_BOX_T_LEFT="┤"

# Double box drawing
export UI_DBOX_HORIZONTAL="═"
export UI_DBOX_VERTICAL="║"
export UI_DBOX_TOP_LEFT="╔"
export UI_DBOX_TOP_RIGHT="╗"
export UI_DBOX_BOTTOM_LEFT="╚"
export UI_DBOX_BOTTOM_RIGHT="╝"

################################################################################
# 💬 TEXT FORMATTING FUNCTIONS
################################################################################

ui_color() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${UI_RESET}"
}

ui_bold() { echo -e "${UI_BOLD}$1${UI_RESET}"; }
ui_italic() { echo -e "${UI_ITALIC}$1${UI_RESET}"; }
ui_underline() { echo -e "${UI_UNDERLINE}$1${UI_RESET}"; }
ui_strikethrough() { echo -e "${UI_STRIKETHROUGH}$1${UI_RESET}"; }
ui_dim() { echo -e "${UI_DIM}$1${UI_RESET}"; }

# Semantic text functions
ui_primary() { ui_color "$UI_PRIMARY" "$1"; }
ui_secondary() { ui_color "$UI_SECONDARY" "$1"; }
ui_success() { ui_color "$UI_SUCCESS" "$1"; }
ui_warning() { ui_color "$UI_WARNING" "$1"; }
ui_danger() { ui_color "$UI_DANGER" "$1"; }
ui_info() { ui_color "$UI_INFO" "$1"; }
ui_muted() { ui_color "$UI_MUTED" "$1"; }
ui_accent() { ui_color "$UI_ACCENT" "$1"; }

# Debug logging functions
ui_debug() {
  if [[ "${MY_DEBUG:-false}" == "true" ]]; then
    ui_color "$UI_MUTED" "🐛 [DEBUG] $1"
  fi
}

ui_debug_vars() {
  if [[ "${MY_DEBUG:-false}" == "true" ]]; then
    ui_debug "Variables:"
    for var in "$@"; do
      ui_color "$UI_MUTED" "  $var = ${(P)var}"
    done
  fi
}

ui_debug_timing() {
  if [[ "${MY_DEBUG:-false}" == "true" ]]; then
    local start_time="$1"
    local operation="$2"
    local end_time=$(date +%s.%N)

    # Use awk for floating-point arithmetic (more portable than bc)
    local duration=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}")
    ui_color "$UI_MUTED" "⏱️  [TIMING] $operation: ${duration}s"
  fi
}

ui_debug_command() {
  if [[ "${MY_DEBUG:-false}" == "true" ]]; then
    ui_color "$UI_MUTED" "💻 [CMD] $*"
  fi
}

# Section headers (hierarchy: section > subtitle > subsection)
ui_section() { echo -e "\n${UI_BOLD}${UI_PRIMARY}$1${UI_RESET}"; }  # Major sections (bold colored)
ui_subtitle() { echo -e "\n${UI_PRIMARY}${UI_ICON_STARTER}${UI_RESET} ${UI_BOLD_WHITE}$1${UI_RESET}"; }  # Subsections with arrow
ui_subsection() { echo -e " ${UI_ACCENT}▸${UI_RESET} ${1}"; }  # Sub-subsections indented

################################################################################
# 📝 MESSAGING COMPONENTS
################################################################################

ui_message() {
    local type="$1"
    local message="$2"
    local icon color

    case "$type" in
        "success") icon="$UI_ICON_SUCCESS"; color="$UI_SUCCESS" ;;
        "error") icon="$UI_ICON_ERROR"; color="$UI_DANGER" ;;
        "warning") icon="$UI_ICON_WARNING"; color="$UI_WARNING" ;;
        "info") icon="$UI_ICON_INFO"; color="$UI_INFO" ;;
        *) icon="$UI_ICON_INFO"; color="$UI_INFO" ;;
    esac

    echo -e "${color}${icon} ${message}${UI_RESET}"
}

ui_success_msg() { ui_message "success" "$1"; }
ui_error_msg() { ui_message "error" "$1"; }
ui_warning_msg() { ui_message "warning" "$1"; }
ui_info_msg() { ui_message "info" "$1"; }

# Alternative simple message functions (colored icons, default text)
ui_success_simple() { 
    local message="$1"
    local space_before="${2:-0}"
    
    # Add spacing before if requested
    for ((i=0; i<space_before; i++)); do
        echo
    done
    
    echo -e "${UI_SUCCESS}${UI_ICON_CHECK_ALT}${UI_RESET} ${message}"
}
ui_error_simple() { echo -e "${UI_DANGER}${UI_ICON_CROSS_ALT}${UI_RESET} ${1}"; }
ui_warning_simple() { echo -e "${UI_WARNING}${UI_ICON_WARN_BRACKET}${UI_RESET} ${1}"; }
ui_info_simple() { echo -e "${UI_INFO}${UI_ICON_INFO_BRACKET}${UI_RESET} ${1}"; }

# Badge-style messages
ui_badge() {
    local type="$1"
    local text="$2"
    local bg_color fg_color

    case "$type" in
        "success") bg_color="$UI_BG_GREEN"; fg_color="$UI_WHITE" ;;
        "error") bg_color="$UI_BG_RED"; fg_color="$UI_WHITE" ;;
        "warning") bg_color="$UI_BG_YELLOW"; fg_color="$UI_BLACK" ;;
        "info") bg_color="$UI_BG_BLUE"; fg_color="$UI_WHITE" ;;
        "primary") bg_color="$UI_BG_BLUE"; fg_color="$UI_WHITE" ;;
        *) bg_color="$UI_BG_BLACK"; fg_color="$UI_WHITE" ;;
    esac

    echo -e "${bg_color}${fg_color} ${text} ${UI_RESET}"
}

################################################################################
# 📊 PROGRESS INDICATORS
################################################################################

ui_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-40}"
    local filled_char="${4:-█}"
    local empty_char="${5:-░}"

    local percentage=$((current * 100 / total))
    local filled_length=$((current * width / total))
    local empty_length=$((width - filled_length))

    local filled=$(printf "%*s" "$filled_length" | tr ' ' "$filled_char")
    local empty=$(printf "%*s" "$empty_length" | tr ' ' "$empty_char")

    echo -ne "\r${UI_PRIMARY}[${filled}${UI_MUTED}${empty}${UI_PRIMARY}] ${percentage}%${UI_RESET}"
}

ui_spinner() {
    local pid="$1"
    local message="${2:-Loading...}"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${UI_PRIMARY}${frames[i]} ${message}${UI_RESET}"
        i=$(((i + 1) % ${#frames[@]}))
        sleep 0.1
    done
    printf "\r${UI_SUCCESS}${UI_ICON_CHECKMARK} ${message} Complete!${UI_RESET}\n"
}

ui_dots_loading() {
    local duration="${1:-3}"
    local message="${2:-Loading}"
    local dots=""

    for ((i=1; i<=duration*4; i++)); do
        case $((i % 4)) in
            1) dots="." ;;
            2) dots=".." ;;
            3) dots="..." ;;
            0) dots="" ;;
        esac
        printf "\r${UI_INFO}${message}${dots}   ${UI_RESET}"
        sleep 0.25
    done
    printf "\r${UI_SUCCESS}${message} Complete!${UI_RESET}\n"
}

################################################################################
# 📦 LAYOUT COMPONENTS
################################################################################

ui_box() {
    local content="$1"
    local title="$2"
    local width="${3:-$((_UI_TERMINAL_WIDTH - 4))}"
    local padding="${4:-1}"

    # Calculate content width
    local content_width=$((width - 2 - 2 * padding))

    # Top border
    echo -e "${UI_PRIMARY}${UI_BOX_TOP_LEFT}$(printf '%*s' $((width - 2)) | tr ' ' "$UI_BOX_HORIZONTAL")${UI_BOX_TOP_RIGHT}${UI_RESET}"

    # Title (if provided)
    if [[ -n "$title" ]]; then
        local title_padding=$(((content_width - ${#title}) / 2))
        echo -e "${UI_PRIMARY}${UI_BOX_VERTICAL}${UI_RESET}$(printf '%*s' $title_padding)${UI_BOLD}${title}${UI_RESET}$(printf '%*s' $((content_width - title_padding - ${#title})))${UI_PRIMARY}${UI_BOX_VERTICAL}${UI_RESET}"
        echo -e "${UI_PRIMARY}${UI_BOX_T_RIGHT}$(printf '%*s' $((width - 2)) | tr ' ' "$UI_BOX_HORIZONTAL")${UI_BOX_T_LEFT}${UI_RESET}"
    fi

    # Content
    echo "$content" | while IFS= read -r line; do
        local padding_str=$(printf '%*s' $padding)
        printf "${UI_PRIMARY}${UI_BOX_VERTICAL}${UI_RESET}%s%-*s%s${UI_PRIMARY}${UI_BOX_VERTICAL}${UI_RESET}\n" \
               "$padding_str" "$content_width" "$line" "$padding_str"
    done

    # Bottom border
    echo -e "${UI_PRIMARY}${UI_BOX_BOTTOM_LEFT}$(printf '%*s' $((width - 2)) | tr ' ' "$UI_BOX_HORIZONTAL")${UI_BOX_BOTTOM_RIGHT}${UI_RESET}"
}

ui_panel() {
    local title="$1"
    local content="$2"
    local type="${3:-info}"
    local border_color

    case "$type" in
        "success") border_color="$UI_SUCCESS" ;;
        "error") border_color="$UI_DANGER" ;;
        "warning") border_color="$UI_WARNING" ;;
        *) border_color="$UI_INFO" ;;
    esac

    local width=$((_UI_TERMINAL_WIDTH - 4))
    local title_line="${border_color}╭─ ${UI_BOLD}${title}${UI_RESET}${border_color} $(printf '%*s' $((width - ${#title} - 6)) | tr ' ' '─')╮${UI_RESET}"

    echo -e "$title_line"
    echo "$content" | while IFS= read -r line; do
        printf "${border_color}│${UI_RESET} %-*s ${border_color}│${UI_RESET}\n" $((width - 2)) "$line"
    done
    echo -e "${border_color}╰$(printf '%*s' $((width - 2)) | tr ' ' '─')╯${UI_RESET}"
}

ui_divider() {
    local char="${1:-─}"
    local width="${2:-$((_UI_TERMINAL_WIDTH))}"
    local color="${3:-$UI_MUTED}"

    echo -e "${color}$(printf '%*s' "$width" | tr ' ' "$char")${UI_RESET}"
}


################################################################################
# 🎯 INTERACTIVE COMPONENTS
################################################################################

ui_confirm() {
    local message="$1"
    local default="${2:-y}"
    local response

    if [[ "$default" == "y" ]]; then
        echo -ne "${UI_QUESTION} ${message} ${UI_MUTED}[Y/n]${UI_RESET} "
    else
        echo -ne "${UI_QUESTION} ${message} ${UI_MUTED}[y/N]${UI_RESET} "
    fi

    read -r response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

ui_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local key

    # Save cursor position and clear area
    echo -ne "\033[s"  # Save cursor position
    echo -e "${UI_INFO} ${prompt}${UI_RESET}"
    echo

    while true; do
        # Display options
        for ((i=0; i<${#options[@]}; i++)); do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${UI_PRIMARY}${UI_ICON_ARROW_RIGHT} ${options[i]}${UI_RESET}"
            else
                echo -e "    ${UI_MUTED}${options[i]}${UI_RESET}"
            fi
        done

        # Read key
        read -s -k1 key
        case "$key" in
            $'\033') # Arrow keys
                read -s -k2 key
                case "$key" in
                    '[A') ((selected > 0)) && ((selected--)) ;;
                    '[B') ((selected < ${#options[@]} - 1)) && ((selected++)) ;;
                esac
                ;;
            $'\n'|$'\r'|'') # Enter (newline, carriage return, or empty)
                # Clear the menu completely
                for ((i=0; i<${#options[@]}; i++)); do
                    echo -ne "\033[A\033[K"
                done
                echo -ne "\033[A\033[K"  # Clear the empty line
                echo -ne "\033[A\033[K"  # Clear the prompt
                return $selected
                ;;
            'q'|'Q') # Quit
                # Clear the menu completely
                for ((i=0; i<${#options[@]}; i++)); do
                    echo -ne "\033[A\033[K"
                done
                echo -ne "\033[A\033[K"  # Clear the empty line
                echo -ne "\033[A\033[K"  # Clear the prompt
                return 255
                ;;
        esac

        # Clear previous options for redraw
        for ((i=0; i<${#options[@]}; i++)); do
            echo -ne "\033[A\033[K"
        done
    done
}

ui_input() {
    local prompt="$1"
    local default="$2"
    local placeholder="${3:-$default}"
    local response

    if [[ -n "$placeholder" ]]; then
        echo -ne "${UI_PRIMARY}❯ ${prompt} ${UI_MUTED}(${placeholder})${UI_RESET}: "
    else
        echo -ne "${UI_PRIMARY}❯ ${prompt}${UI_RESET}: "
    fi

    read -r response
    echo "${response:-$default}"
}

################################################################################
# 📋 TABLE COMPONENTS
################################################################################

ui_table() {
    local headers="$1"
    local rows="$2"
    local separator="${3:-│}"

    # Split headers and rows by newlines and tabs
    local -a header_array=("${(@s/	/)headers}")
    local -a row_array=("${(@f)rows}")

    # Calculate column widths
    local -a widths
    local max_cols=${#header_array[@]}

    # Initialize widths with header lengths
    for ((i=1; i<=max_cols; i++)); do
        widths[i]=${#header_array[i]}
    done

    # Check row data for max widths
    for row in "${row_array[@]}"; do
        local -a cols=("${(@s/	/)row}")  # Split on tab
        for ((i=1; i<=${#cols[@]}; i++)); do
            if [[ ${#cols[i]} -gt ${widths[i]:-0} ]]; then
                widths[i]=${#cols[i]}
            fi
        done
    done

    # Print headers
    local header_line=""
    local divider_line=""
    for ((i=1; i<=max_cols; i++)); do
        header_line+="${UI_BOLD}$(printf "%-*s" ${widths[i]} "${header_array[i]}")${UI_RESET}"
        divider_line+="$(printf '%*s' ${widths[i]} | tr ' ' '─')"
        if [[ $i -lt $max_cols ]]; then
            header_line+=" ${UI_MUTED}${separator}${UI_RESET} "
            divider_line+="─┼─"
        fi
    done

    echo -e "$header_line"
    echo -e "${UI_MUTED}$divider_line${UI_RESET}"

    # Print rows
    for row in "${row_array[@]}"; do
        local -a cols=("${(@s/	/)row}")  # Split on tab
        local row_line=""
        for ((i=1; i<=max_cols; i++)); do
            row_line+="$(printf "%-*s" ${widths[i]} "${cols[i]:-}")"
            if [[ $i -lt $max_cols ]]; then
                row_line+=" ${UI_MUTED}${separator}${UI_RESET} "
            fi
        done
        echo -e "$row_line"
    done
}

################################################################################
# 🎬 ANIMATION EFFECTS
################################################################################

ui_typewriter() {
    local text="$1"
    local delay="${2:-0.05}"
    local color="${3:-$UI_RESET}"

    echo -ne "${color}"
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep "$delay"
    done
    echo -e "${UI_RESET}"
}

ui_fade_in() {
    local text="$1"
    local steps="${2:-5}"

    for ((i=1; i<=steps; i++)); do
        local opacity=$((i * 100 / steps))
        echo -ne "\r${UI_DIM}${text}${UI_RESET}"
        sleep 0.1
    done
    echo -ne "\r${text}${UI_RESET}\n"
}

ui_pulse() {
    local text="$1"
    local count="${2:-3}"

    for ((i=1; i<=count; i++)); do
        echo -ne "\r${UI_BOLD}${text}${UI_RESET}"
        sleep 0.3
        echo -ne "\r${UI_DIM}${text}${UI_RESET}"
        sleep 0.3
    done
    echo -ne "\r${text}${UI_RESET}\n"
}

################################################################################
# 🚀 UTILITY FUNCTIONS
################################################################################

ui_clear_line() {
    echo -ne "\033[2K\r"
}

ui_save_cursor() {
    echo -ne "\033[s"
}

ui_restore_cursor() {
    echo -ne "\033[u"
}

ui_hide_cursor() {
    echo -ne "\033[?25l"
}

ui_show_cursor() {
    echo -ne "\033[?25h"
}

ui_move_cursor() {
    local row="$1"
    local col="$2"
    echo -ne "\033[${row};${col}H"
}

ui_terminal_size() {
    echo "${_UI_TERMINAL_WIDTH}x${_UI_TERMINAL_HEIGHT}"
}

ui_center_text() {
    local text="$1"
    local width="${2:-$_UI_TERMINAL_WIDTH}"
    local padding=$(((width - ${#text}) / 2))
    printf "%*s%s%*s\n" $padding "" "$text" $((width - padding - ${#text})) ""
}

################################################################################
# 🎨 THEME PRESETS
################################################################################

ui_theme_dark() {
    export UI_PRIMARY='\033[38;5;227m'    # Light yellow
    export UI_SUCCESS='\033[38;5;83m'     # Light green
    export UI_WARNING='\033[38;5;221m'    # Light yellow
    export UI_DANGER='\033[38;5;203m'     # Light red
    export UI_MUTED='\033[38;5;240m'      # Dark gray
}

ui_theme_light() {
    export UI_PRIMARY='\033[38;5;178m'    # Dark yellow
    export UI_SUCCESS='\033[38;5;28m'     # Dark green
    export UI_WARNING='\033[38;5;166m'    # Dark orange
    export UI_DANGER='\033[38;5;124m'     # Dark red
    export UI_MUTED='\033[38;5;247m'      # Light gray
}

ui_theme_cyberpunk() {
    export UI_PRIMARY='\033[38;5;51m'     # Cyan (keep for ocean theme)
    export UI_SUCCESS='\033[38;5;46m'     # Neon green
    export UI_WARNING='\033[38;5;226m'    # Neon yellow
    export UI_DANGER='\033[38;5;201m'     # Neon pink
    export UI_ACCENT='\033[38;5;51m'      # Bright cyan (ocean theme)
    export UI_MUTED='\033[38;5;240m'      # Dark gray
}

################################################################################
# 📋 STEP PROGRESS TRACKING
################################################################################

# Installation progress tracking (migrated from helper.zsh)
_CURRENT_STEP=0
_TOTAL_STEPS=0

ui_set_total_steps() {
    _TOTAL_STEPS=$1
    _CURRENT_STEP=0
}

ui_next_step() {
    ((_CURRENT_STEP++))
    ui_info_simple "Step ${_CURRENT_STEP}/${_TOTAL_STEPS}: $1"
}

################################################################################
# 🎯 TASK MANAGEMENT
################################################################################

# Task execution functions (migrated from helper.zsh)
ui_task_start() {
    echo -e "${UI_CYAN}🚀 ${UI_RESET}$1..."
}

ui_task_done() {
    echo -e "${UI_SUCCESS}${UI_ICON_CHECK} ${UI_RESET}$1 done!"
}

ui_final_success() {
    echo -e "${UI_SUCCESS}👍 Process completed successfully!${UI_RESET}"
}

ui_final_fail() {
    echo -e "${UI_DANGER}🚫 Process failed!${UI_RESET}"
}

################################################################################
# 📝 TEXT STYLING
################################################################################

# Enhanced text styling functions
ui_styled() {
    local style="$1"
    local text="$2"
    case "$style" in
        "bold") echo -e "${UI_BOLD_WHITE}${text}${UI_RESET}" ;;
        "highlight") echo -e "${UI_MAGENTA}${text}${UI_RESET}" ;;
        "subtle") echo -e "${UI_MUTED}${text}${UI_RESET}" ;;
        *) echo "$text" ;;
    esac
}

# Convenience aliases for styling
ui_bold_text() { ui_styled "bold" "$1"; }
ui_highlight() { ui_styled "highlight" "$1"; }
ui_subtle() { ui_styled "subtle" "$1"; }

################################################################################
# 📐 LAYOUT HELPERS
################################################################################

# Enhanced spacer function
ui_spacer() {
    local count=${1:-1}
    for ((i=1; i<=count; i++)); do
        printf "\n"
    done
}

# Horizontal rule function
ui_hr() {
    echo -e "${UI_PRIMARY}────────────────────────────────────────${UI_RESET}"
    if [[ -n "$1" ]]; then
        echo "$1"
        echo -e "${UI_PRIMARY}────────────────────────────────────────${UI_RESET}"
    fi
}

################################################################################
# 🏷️ SECTION HEADERS
################################################################################

# Title functions for section headers
# Legacy title function (deprecated - use ui_section instead)
ui_title() {
    echo -e "${UI_CYAN}${UI_ICON_STARTER} $@${UI_RESET}"
}

ui_title_action() {
    local action="$1"
    local target="$2"
    ui_title "${action}" "${target}..."
}

# Convenience aliases for common actions
ui_title_install() { ui_title_action "Installing" "$1"; }
ui_title_update() { ui_title_action "Updating" "$1"; }

################################################################################
# 💬 USER INTERACTION
################################################################################

# User input prompt
ui_user_prompt() {
    echo -e "${UI_WARNING}${UI_ICON_INFO_BRACKET}${UI_RESET} $1"
}

ui_input_prompt() {
    echo -e "${UI_PRIMARY}[>]${UI_RESET} $1"
}

################################################################################
# 🔄 BACKWARD COMPATIBILITY FUNCTIONS
################################################################################

# Migration functions for helper.zsh functions
# These provide backward compatibility during the transition period

# Message functions
echo_info() { ui_info_simple "$@"; }
echo_success() { ui_success_simple "$@"; }
echo_fail() { ui_error_simple "$1"; [[ -n "$2" ]] && exit "$2" || exit 1; }
echo_warn() { ui_warning_simple "$@"; }
echo_user() { ui_user_prompt "$@"; }
echo_task_start() { ui_task_start "$@"; }
echo_task_done() { ui_task_done "$@"; }
echo_input() { ui_input_prompt "$@"; }
echo_final_success() { ui_final_success "$@"; }
echo_final_fail() { ui_final_fail "$@"; }

# Title and styling functions
echo_title() { ui_title "$@"; }
echo_subtitle() { ui_subtitle "$@"; }
echo_title_action() { ui_title_action "$@"; }
echo_title_install() { ui_title_install "$@"; }
echo_title_update() { ui_title_update "$@"; }
echo_bold() { ui_bold_text "$@"; }
echo_highlight() { ui_highlight "$@"; }
echo_subtle() { ui_subtle "$@"; }
echo_styled() { ui_styled "$@"; }

# Layout functions
echo_space() { ui_spacer "$@"; }
echo_spacex2() { ui_spacer 2 "$@"; }
echo_spacex3() { ui_spacer 3 "$@"; }
echo_hr() { ui_hr "$@"; }

# Step tracking functions
set_total_steps() { ui_set_total_steps "$@"; }
next_step() { ui_next_step "$@"; }

################################################################################
# 🎯 INITIALIZATION
################################################################################

# Auto-detect and set appropriate theme
if [[ -n "$TERM" ]] && [[ "$TERM" != "dumb" ]]; then
    # Default to dark theme for modern terminals
    ui_theme_dark
fi

# Cleanup function
ui_cleanup() {
    ui_show_cursor
    echo -e "${UI_RESET}"
}

# Register cleanup on script exit (only if not already set)
if [[ -z "${_UI_CLEANUP_TRAP_SET}" ]]; then
    trap ui_cleanup EXIT
    _UI_CLEANUP_TRAP_SET=1
fi
