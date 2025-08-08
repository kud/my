
############################################################
# 🗂️  Basic Directory Operations
############################################################
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'

alias d='dirs -v'          # Print contents of the directory stack
alias -- -='cd -'          # Go to previous directory

# Generate numbered directory aliases (1-9) efficiently
for i in {1..9}; do alias "$i"="cd +$i"; done


############################################################
# ⚡ Super User
############################################################
alias _='sudo'


############################################################
# 📁 List Directory Contents
############################################################
alias l='lsd -la --git'


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
alias nvimconfig='$EDITOR ~/.config/nvim/init.lua'
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
alias vim='nvim'
alias copilot='gh copilot'

# Useful utility aliases
alias e='${(z)VISUAL:-${(z)EDITOR}}'  # Quick editor
alias p='${(z)PAGER}'                # Quick pager
alias type='type -a'                 # Show all locations of command

alias pbc='pbcopy'
alias pbp='pbpaste'


############################################################
# 🚫 No Correct (Essential Only)
############################################################
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias cp='nocorrect cp'
alias ln='nocorrect ln'


############################################################
# 🚫 No Glob
############################################################
alias jake='noglob jake'
alias npm='noglob npm'
alias bower='noglob bower'
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'
