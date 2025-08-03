#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎬 ENVIRONMENT WELCOME SCREEN                                              #
#   -----------------------------                                              #
#   Displays the beautiful ASCII art welcome banner for the development       #
#   environment setup process. Creates a professional first impression.       #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

################################################################################
# 🎨 WELCOME BANNER
################################################################################

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
