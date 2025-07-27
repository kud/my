
############################################################
# 🗂️  Basic Directory Operations
############################################################
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'

alias d='dirs -v'          # Print contents of the directory stack
alias -- -='cd -'          # Go to previous directory

alias 1='cd +1'
alias 2='cd +2'
alias 3='cd +3'
alias 4='cd +4'
alias 5='cd +5'
alias 6='cd +6'
alias 7='cd +7'
alias 8='cd +8'
alias 9='cd +9'


############################################################
# ⚡ Super User
############################################################
alias _='sudo'


############################################################
# 📁 List Directory Contents
############################################################
alias l='lsd -la --git'
# alias lg='exa -la --git'
# alias ll='exa -l --git'
# alias llg='exa -l --git'
# alias le='exa -a -T -L=1 --git'


############################################################
# 🗄️  Ease Folder Creation
############################################################
alias md=mkdir


############################################################
# 📝 Verbose
############################################################
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -i'


############################################################
# 📦 Show Folders Size
############################################################
alias filesizer='du -sc * | sort -n | tail'


############################################################
# ⚙️  Config
############################################################
alias .profile='$EDITOR -n ~/.profile'
alias .zshrc='$EDITOR -n  ~/.zshrc'
alias .zshrc_local='$EDITOR -n  ~/.zshrc_local'
alias .npmrc='$EDITOR -n  ~/.npmrc'
alias .vimrc='$EDITOR -n  ~/.vimrc'
alias sshconfig='$EDITOR -n  ~/.ssh/config'
alias .aliases='$EDITOR -n  ~/.aliases'
alias hosts='$EDITOR -n  /private/etc/hosts'
alias php.ini='$EDITOR -n  /private/etc/php.ini'
alias .gitignore_global='$EDITOR -n  ~/.gitignore_global'
alias .gitconfig='$EDITOR -n  ~/.gitconfig'
alias .gitconfig_local='$EDITOR -n  ~/.gitconfig_local'
alias network-sharing='sudo $EDITOR -n /etc/bootpd.plist'
alias dnsmasq.conf='$EDITOR -n ${HOMEBREW_PREFIX}/etc/dnsmasq.conf'


############################################################
# 🤖 Android
############################################################
alias android-inspector='adb forward tcp:9222 localabstract:chrome_devtools_remote'
alias adb-logcat='adb logcat browser:IEW "*:S"'


############################################################
# 📦 (Un)Compression
############################################################
alias tarls='tar -tf'
alias tgz='tar -czf'
alias untar='tar -vxf'
alias untgz='tar -vzxf'


############################################################
# 👀 Quicklook
############################################################
alias klook='qlmanage -p'


############################################################
# 🧶 Yarn
############################################################
alias yarn-check='yarn upgrade-interactive --latest'


############################################################
# 🚀 Ease
############################################################
alias c='code .'
alias about='fastfetch'
alias dns-flush='sudo killall -HUP mDNSResponder'
alias shell-reload='exec $SHELL'
alias gem-back='gem pristine --all --only-executables'
alias please='sudo $(fc -ln -1)'
alias allo='ping 8.8.8.8'
alias dl='curl -O'
alias wtf='whence -v'
alias npms='npm run start'
alias wt='webtorrent --vlc --not-on-top download'


############################################################
# 🚫 No Correct
############################################################
alias sshfs='nocorrect sshfs'


############################################################
# 🚫 No Glob
############################################################
alias jake='noglob jake'
alias npm='noglob npm'
