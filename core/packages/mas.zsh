#! /usr/bin/env zsh
source $MY/core/utils/helper.zsh

echo_space
echo_title_install "apps from AppStore"

source $MY/profiles/$OS_PROFILE/core/packages/mas.zsh 2> /dev/null

echo_space
echo_title_update "apps from AppStore"

mas upgrade
