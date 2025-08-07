#! /usr/bin/env zsh
source $MY/core/utils/helper.zsh

source $MY/profiles/$OS_PROFILE/core/packages/mas.zsh 2> /dev/null

mas upgrade
