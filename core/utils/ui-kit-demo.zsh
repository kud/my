#!/usr/bin/env zsh

################################################################################
#                                                                              #
#    MODERN ZSH UI KIT DEMO                                                  #
#   -----------------------                                                    #
#   Interactive demonstration of all UI Kit components and features.          #
#   Run this script to see the full capabilities of the modern Zsh UI Kit.    #
#                                                                              #
################################################################################

# Load the UI Kit
source "$(dirname "$0")/ui-kit.zsh"

# Demo configuration
DEMO_DELAY=1.5
FAST_DELAY=0.8

# Clear screen and start demo
clear
ui_hide_cursor

demo_header() {
    ui_spacer 2
    ui_center_text "${UI_ICON_STAR} MODERN ZSH UI KIT DEMONSTRATION"
    ui_center_text "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ui_spacer 2
}

demo_section() {
    local title="$1"
    ui_spacer 2
    ui_divider "━"
    ui_spacer 1
    echo -e "  $(ui_bold "$(ui_accent "$title")")"
    ui_spacer 1
}

demo_colors() {
    demo_section "${UI_ICON_STAR} COLOR PALETTE"

    echo "Basic Colors:"
    echo -e "  $(ui_color "$UI_RED" "Red") | $(ui_color "$UI_GREEN" "Green") | $(ui_color "$UI_BLUE" "Blue") | $(ui_color "$UI_YELLOW" "Yellow")"
    echo -e "  $(ui_color "$UI_MAGENTA" "Magenta") | $(ui_color "$UI_CYAN" "Cyan") | $(ui_color "$UI_WHITE" "White") | $(ui_color "$UI_BRIGHT_BLACK" "Gray")"

    ui_spacer 1
    echo "Semantic Colors:"
    echo -e "  $(ui_primary "Primary") | $(ui_success "Success") | $(ui_warning "Warning") | $(ui_danger "Danger")"
    echo -e "  $(ui_info "Info") | $(ui_secondary "Secondary") | $(ui_accent "Accent") | $(ui_muted "Muted")"

    ui_spacer 1
    echo "Text Styles:"
    echo -e "  $(ui_bold "Bold") | $(ui_italic "Italic") | $(ui_underline "Underlined") | $(ui_strikethrough "Strikethrough") | $(ui_dim "Dimmed")"

    sleep $DEMO_DELAY
}

demo_icons() {
    demo_section "${UI_ICON_MOBILE:-$UI_ICON_STAR} ICONS & SYMBOLS"

    echo "Status Icons:"
    echo -e "  $UI_ICON_SUCCESS Success | $UI_ICON_ERROR Error | $UI_ICON_WARNING Warning | $UI_ICON_INFO Info"

    ui_spacer 1
    echo "Action Icons:"
    echo -e "  $UI_ICON_DOWNLOAD Download | $UI_ICON_UPLOAD Upload | $UI_ICON_INSTALL Install | $UI_ICON_DELETE Delete"
    echo -e "  $UI_ICON_EDIT Edit | $UI_ICON_SEARCH Search | $UI_ICON_SETTINGS Settings | $UI_ICON_REFRESH Refresh"

    ui_spacer 1
    echo "Arrows & Navigation:"
    echo -e "  $UI_ICON_ARROW_RIGHT Right | $UI_ICON_ARROW_LEFT Left | $UI_ICON_ARROW_UP Up | $UI_ICON_ARROW_DOWN Down"

    ui_spacer 1
    echo "Fun Icons:"
    echo -e "  $UI_ICON_ROCKET Rocket | $UI_ICON_FIRE Fire | $UI_ICON_STAR Star | $UI_ICON_HEART Heart | $UI_ICON_THUMBS_UP Thumbs Up"

    sleep $DEMO_DELAY
}

demo_messages() {
    demo_section "${UI_ICON_CHAT:-$UI_ICON_INFO} MESSAGING COMPONENTS"

    echo "Standard Messages:"
    ui_success_msg "Operation completed successfully!"
    ui_info_msg "Here's some helpful information for you."
    ui_warning_msg "Please be careful with this action."
    ui_error_msg "Something went wrong, please try again."

    ui_spacer 1
    echo "Simple Alternative Messages:"
    ui_success_simple "Operation completed successfully!"
    ui_info_simple "Here's some helpful information for you."
    ui_warning_simple "Please be careful with this action."
    ui_error_simple "Something went wrong, please try again."

    ui_spacer 1
    echo "Badge Messages:"
    echo -e "  $(ui_badge "success" "DONE") $(ui_badge "error" "FAILED") $(ui_badge "warning" "CAUTION") $(ui_badge "info" "NEW")"
    echo -e "  $(ui_badge "primary" "FEATURED") $(ui_badge "default" "NORMAL")"

    ui_spacer 1
    echo "Pill Tags:"
    echo -e "  $(ui_pill "success" "v2.1.0") $(ui_pill "danger" "breaking") $(ui_pill "warning" "beta") $(ui_pill "info" "stable")"
    echo -e "  $(ui_pill "major" "major") $(ui_pill "minor" "minor") $(ui_pill "patch" "patch") $(ui_pill "muted" "deprecated")"
    echo -e "  $(ui_pill "accent" "featured") $(ui_pill_custom 93 "custom-color")"

    sleep $DEMO_DELAY
}

demo_progress() {
    demo_section "${UI_ICON_INFO} PROGRESS INDICATORS"

    echo "Progress Bar Animation:"
    for i in {0..20}; do
        ui_progress_bar $i 20 50
        sleep 0.1
    done
    echo

    ui_spacer 1
    echo "Different Progress Bar Styles:"
    ui_progress_bar 15 20 30 "█" "░"
    echo
    ui_progress_bar 12 20 30 "▓" "░"
    echo
    ui_progress_bar 8 20 30 "●" "○"
    echo

    ui_spacer 1
    echo "Dots Loading Animation:"
    ui_dots_loading 2 "Processing data"

    sleep $FAST_DELAY
}

demo_layout() {
    demo_section "${UI_ICON_INSTALL} LAYOUT COMPONENTS"

    echo "Simple Box:"
    ui_box "This is content inside a simple box.\nIt can contain multiple lines.\nAnd preserves formatting!" "Sample Box"

    ui_spacer 1
    echo "Panels with Different Types:"
    ui_panel "Success Panel" "Everything is working perfectly!\nAll systems are operational." "success"

    ui_spacer 1
    ui_panel "Warning Panel" "Please review these settings before proceeding.\nSome actions cannot be undone." "warning"

    ui_spacer 1
    ui_panel "Error Panel" "Critical system error detected.\nImmediate attention required." "error"

    ui_spacer 1
    echo "Dividers:"
    ui_divider "─" 50 "$UI_PRIMARY"
    ui_divider "═" 40 "$UI_SUCCESS"
    ui_divider "•" 30 "$UI_WARNING"
    ui_divider "~" 35 "$UI_INFO"

    sleep $DEMO_DELAY
}

demo_tables() {
    demo_section "${UI_ICON_TABLE} TABLE COMPONENTS"

    echo "Sample Data Table:"
    local headers="Name	Status	Version	Size"
    local rows="ui-kit.zsh	$UI_ICON_CHECKMARK Active	v2.1.0	15.2KB
helper.zsh	$UI_ICON_CHECKMARK Active	v1.8.3	8.7KB
package-manager.zsh	$UI_ICON_CROSS Removed	v1.0.0	-
profile-manager.zsh	$UI_ICON_CROSS Removed	v1.0.0	-"

    ui_table "$headers" "$rows"

    sleep $DEMO_DELAY
}

demo_interactive() {
    demo_section "${UI_ICON_STAR} INTERACTIVE COMPONENTS"

    echo "Input Field Demo:"
    local name=$(ui_input "What's your name?" "Anonymous" "Enter your name")
    ui_success_msg "Hello, $name!"

    ui_spacer 1
    echo "Confirmation Dialog:"
    if ui_confirm "Do you want to continue the demo?"; then
        ui_success_msg "Great! Continuing with the demo..."
    else
        ui_warning_msg "Demo interrupted by user choice."
        return
    fi

    ui_spacer 1
    echo "Selection Menu (use arrow keys and Enter):"
    local options=("${UI_ICON_STAR} Dark Theme" "${UI_ICON_STAR} Light Theme" "${UI_ICON_INFO} Ocean Theme" "${UI_ICON_FORWARD} Skip Theme Selection")
    ui_select "Choose a theme to apply:" "${options[@]}"
    local choice=$?

    case $choice in
        0) ui_theme_dark; ui_success_msg "Applied Dark Theme!" ;;
        1) ui_theme_light; ui_success_msg "Applied Light Theme!" ;;
        2) ui_theme_cyberpunk; ui_success_msg "Applied Ocean Theme!" ;;
        3) ui_info_msg "Theme selection skipped." ;;
        255) ui_warning_msg "Selection cancelled." ;;
    esac

    sleep $FAST_DELAY
}

demo_animations() {
    demo_section "${UI_ICON_STAR} ANIMATION EFFECTS"

    echo "Typewriter Effect:"
    ui_typewriter "This text appears letter by letter..." 0.08 "$UI_PRIMARY"

    ui_spacer 1
    echo "Pulse Animation:"
    ui_pulse "This text pulses to get attention!" 2

    ui_spacer 1
    echo "Fade In Effect:"
    ui_fade_in "This text fades in gradually..."

    sleep $DEMO_DELAY
}

demo_advanced() {
    demo_section "${UI_ICON_ROCKET} ADVANCED FEATURES"

    echo "Box Drawing Characters:"
    echo -e "${UI_PRIMARY}"
    echo "┌─────────────────────────────────┐"
    echo "│         Complex Layout          │"
    echo "├─────────────────────────────────┤"
    echo "│ ${UI_ICON_CHECKMARK} Feature 1: Modern UI         │"
    echo "│ ${UI_ICON_CHECKMARK} Feature 2: Rich Colors       │"
    echo "│ ${UI_ICON_CHECKMARK} Feature 3: Animations        │"
    echo "│ ${UI_ICON_CHECKMARK} Feature 4: Interactivity     │"
    echo "└─────────────────────────────────┘"
    echo -e "${UI_RESET}"

    ui_spacer 1
    echo "Terminal Information:"
    echo -e "  Terminal Size: $(ui_accent "$(ui_terminal_size)")"
    echo -e "  Color Support: $(ui_accent "${_UI_SUPPORTS_256_COLORS} colors")"
    echo -e "  Unicode Support: $(ui_accent "$([[ $_UI_SUPPORTS_UNICODE == true ]] && echo "Yes" || echo "No")")"

    ui_spacer 1
    echo "Cursor Control Demo:"
    echo -n "Saving cursor position... "
    ui_save_cursor
    sleep 1
    echo "Moving cursor..."
    ui_move_cursor 5 40
    echo -ne "$(ui_danger "[Moved!]")"
    sleep 1.5
    ui_restore_cursor
    echo "Restored!"

    sleep $DEMO_DELAY
}

demo_real_world() {
    demo_section "${UI_ICON_GLOBE} REAL-WORLD EXAMPLE"

    echo "Package Installation Simulation:"
    ui_spacer 1

    local packages=("nodejs" "typescript" "eslint" "prettier" "webpack")
    local total=${#packages[@]}

    ui_info_msg "Installing $total development packages..."
    ui_spacer 1

    for ((i=1; i<=total; i++)); do
        local package="${packages[i]}"
        echo -ne "$(ui_primary "${UI_ICON_PROMPT}") Installing $package... "

        # Simulate installation time
        sleep 0.5

        ui_progress_bar $i $total 20
        echo -ne "  "
        echo -e "$(ui_color "$UI_SUCCESS" "$UI_ICON_CHECKMARK") $package installed"
        sleep 0.3
    done

    ui_spacer 1
    ui_success_msg "All packages installed successfully!"

    ui_spacer 1
    ui_panel "Installation Summary" "${UI_ICON_CHECKMARK} 5 packages installed
${UI_ICON_CHECKMARK} 0 errors encountered
${UI_ICON_CHECKMARK} 3.2s total time
${UI_ICON_BOLT} Ready for development!" "success"

    sleep $DEMO_DELAY
}

demo_finale() {
    ui_spacer 2
    ui_divider "━"
    ui_spacer 1

    ui_center_text "${UI_ICON_STAR} UI KIT DEMO COMPLETE!"
    ui_spacer 1
    ui_center_text "$(ui_muted "Thank you for exploring the Modern Zsh UI Kit")"

    ui_spacer 1
    echo -e "  $(ui_bold "Key Features Demonstrated:")"
    echo -e '    '$(ui_success "$UI_ICON_CHECKMARK")' Rich color palette with semantic colors'
    echo -e '    '$(ui_success "$UI_ICON_CHECKMARK")' Modern icons and symbols'
    echo -e '    '$(ui_success "$UI_ICON_CHECKMARK")' Interactive components and animations'
    echo -e '    '$(ui_success "$UI_ICON_CHECKMARK")' Layout tools (boxes, panels, tables)'
    echo -e '    '$(ui_success "$UI_ICON_CHECKMARK")' Progress indicators and loading states'
    echo -e '    '$(ui_success "$UI_ICON_CHECKMARK")' Real-world usage examples'

    ui_spacer 1
    ui_info_msg "Source the ui-kit.zsh file in your scripts to start using these components!"

    ui_spacer 2
    ui_show_cursor
}

# Main demo execution
main() {
    demo_header
    demo_colors
    demo_icons
    demo_messages
    demo_progress
    demo_layout
    demo_tables
    demo_interactive
    demo_animations
    demo_advanced
    demo_real_world
    demo_finale
}

# Handle interruption gracefully
trap 'ui_show_cursor; ui_cleanup; exit 0' INT

# Run the demo
main

# Cleanup
ui_cleanup
