#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎬 ANIMATED INTRO BANNER                                                   #
#   ------------------------                                                   #
#   Displays an animated welcome screen with the My! Oh My! logo.             #
#   Runs asynchronously to avoid blocking the update process.                 #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

################################################################################
# 🎨 ANIMATED WELCOME BANNER
################################################################################

# Function to show animated intro
show_animated_intro() {
    # Array of rainbow colors for animation
    local colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 87 123 159 195)
    local fade_colors=(255 254 253 252 251 250 249 248 247 246 245 244 243 242 241 240)
    
    # Clear screen and position cursor at top
    printf "\033[2J\033[H"
    
    # Hide cursor during animation
    printf "\033[?25l"
    
    # Animated rainbow effect on logo
    for ((i=0; i<${#colors[@]}; i++)); do
        local color=${colors[$i]}
        printf "\033[H\033[10C"
        
        printf "\033[38;5;${color}m███╗   ███╗██╗   ██╗\033[0m\n"
        printf "\033[10C\033[38;5;${color}m████╗ ████║╚██╗ ██╔╝\033[0m\n"
        printf "\033[10C\033[38;5;${color}m██╔████╔██║ ╚████╔╝ \033[0m\n"
        printf "\033[10C\033[38;5;${color}m██║╚██╔╝██║  ╚██╔╝  \033[0m\n"
        printf "\033[10C\033[38;5;${color}m██║ ╚═╝ ██║   ██║   \033[0m\n"
        printf "\033[10C\033[38;5;${color}m╚═╝     ╚═╝   ╚═╝   \033[0m\n"
        
        sleep 0.04
    done
    
    # Final display in bright cyan
    printf "\033[H\033[10C"
    printf "\033[96m███╗   ███╗██╗   ██╗\033[0m\n"
    printf "\033[10C\033[96m████╗ ████║╚██╗ ██╔╝\033[0m\n"
    printf "\033[10C\033[96m██╔████╔██║ ╚████╔╝ \033[0m\n"
    printf "\033[10C\033[96m██║╚██╔╝██║  ╚██╔╝  \033[0m\n"
    printf "\033[10C\033[96m██║ ╚═╝ ██║   ██║   \033[0m\n"
    printf "\033[10C\033[96m╚═╝     ╚═╝   ╚═╝   \033[0m\n"
    
    # Typewriter effect for tagline
    printf "\n\033[10C\033[90m"
    local tagline="My own environment for macOS"
    for (( j=0; j<${#tagline}; j++ )); do
        printf "%s" "${tagline:$j:1}"
        sleep 0.02
    done
    printf "\033[0m\n"
    
    # Quick loading animation
    printf "\n\033[10C"
    local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    for ((k=0; k<20; k++)); do
        printf "\r\033[10C\033[92m${spinner[$((k % 10))]} Starting update...\033[0m"
        sleep 0.05
    done
    
    # Clear the line completely and show final ready message
    printf "\r\033[K\033[10C\033[92m${UI_ICON_BOLT} Let's go!\033[0m\n\n"
    
    # Restore cursor
    printf "\033[?25h"
}

# Process cleanup function
cleanup_intro_process() {
    if [[ -n "$MY_INTRO_PID" ]]; then
        # Check if process is still running
        if kill -0 "$MY_INTRO_PID" 2>/dev/null; then
            # Terminate the background process gracefully
            kill -TERM "$MY_INTRO_PID" 2>/dev/null
            # Give it a moment to terminate gracefully
            sleep 0.1
            # Force kill if still running
            if kill -0 "$MY_INTRO_PID" 2>/dev/null; then
                kill -KILL "$MY_INTRO_PID" 2>/dev/null
            fi
        fi
        unset MY_INTRO_PID
    fi
}

# Function to run intro asynchronously
run_intro_async() {
    # Check if we should show intro (not in CI, interactive terminal, and during update)
    if [[ -z "$CI" ]] && [[ -t 1 ]] && [[ "$MY_SHOW_INTRO" == "true" ]]; then
        # Run animation in background subshell
        (
            show_animated_intro
        ) &
        
        # Store the PID if needed for cleanup
        export MY_INTRO_PID=$!
        
        # Set up cleanup traps for the background process
        # Robust trap checking: only set if not present as a standalone command
        local trap_cmd
        trap_cmd=$(trap -p EXIT | awk -F"'" '{print $2}')
        if [[ ! "$trap_cmd" =~ "(^|;)cleanup_intro_process($|;)" ]]; then
            trap cleanup_intro_process EXIT
        fi
        
        trap_cmd=$(trap -p INT | awk -F"'" '{print $2}')
        if [[ ! "$trap_cmd" =~ "(^|;)cleanup_intro_process($|;)" ]]; then
            trap cleanup_intro_process INT
        fi
        
        trap_cmd=$(trap -p TERM | awk -F"'" '{print $2}')
        if [[ ! "$trap_cmd" =~ "(^|;)cleanup_intro_process($|;)" ]]; then
            trap cleanup_intro_process TERM
        fi
        # Use a flag variable to ensure traps are only set once
        if [[ -z "$MY_INTRO_TRAPS_SET" ]]; then
            trap cleanup_intro_process EXIT
            trap cleanup_intro_process INT
            trap cleanup_intro_process TERM
            export MY_INTRO_TRAPS_SET=true
        fi
        # Don't wait - let the main process continue
        # The animation will complete on its own
    else
        # Fallback to simple banner if not animating
        echo_space
        printf "${COLOUR_YELLOW}"
        
        printf "\n    ${COLOUR_YELLOW}███${COLOUR_BLACK}╗   ${COLOUR_YELLOW}███${COLOUR_BLACK}╗${COLOUR_YELLOW}██${COLOUR_BLACK}╗   ${COLOUR_YELLOW}██${COLOUR_BLACK}╗"
        printf "\n    ${COLOUR_YELLOW}████${COLOUR_BLACK}╗ ${COLOUR_YELLOW}████${COLOUR_BLACK}║╚${COLOUR_YELLOW}██${COLOUR_BLACK}╗ ${COLOUR_YELLOW}██${COLOUR_BLACK}╔╝"
        printf "\n    ${COLOUR_YELLOW}██${COLOUR_BLACK}╔${COLOUR_YELLOW}████${COLOUR_BLACK}╔${COLOUR_YELLOW}██${COLOUR_BLACK}║ ╚${COLOUR_YELLOW}████${COLOUR_BLACK}╔╝ "
        printf "\n    ${COLOUR_YELLOW}██${COLOUR_BLACK}║╚${COLOUR_YELLOW}██${COLOUR_BLACK}╔╝${COLOUR_YELLOW}██${COLOUR_BLACK}║  ╚${COLOUR_YELLOW}██${COLOUR_BLACK}╔╝ "
        printf "\n    ${COLOUR_YELLOW}██${COLOUR_BLACK}║ ╚═╝ ${COLOUR_YELLOW}██${COLOUR_BLACK}║   ${COLOUR_YELLOW}██${COLOUR_BLACK}║   "
        printf "\n    ${COLOUR_BLACK}╚═╝     ╚═╝   ╚═╝  "
        
        printf "\n${COLOUR_RESET}"
        echo_space
        echo_space
    fi
}

# If run directly (not sourced), show animated intro
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]] || [[ "${ZSH_EVAL_CONTEXT}" == "cmdarg" ]]; then
    show_animated_intro
else
    # When sourced from update, use async version
    run_intro_async
fi