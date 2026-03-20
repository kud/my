
# 🗂️ Directory Navigation
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'
alias d='dirs -v'
alias -- -='cd -'
for i in {1..9}; do alias "$i"="cd +$i"; done

# ⚡ Super User
alias _='sudo'

# 📁 Directory Listing
alias l='lsd -la --git'

# 🗄️ Folder Creation
alias md=mkdir

# 📝 Verbose Operations
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -i'

# 📦 Folder Size
alias filesizer='du -sc * | sort -n | tail'

# ⚙️ Config Files
alias .profile='$EDITOR -n ~/.profile'
alias .zshrc='$EDITOR -n  ~/.zshrc'
alias zlocal='$EDITOR -n  ~/.config/zsh/local.zsh'
alias .npmrc='$EDITOR -n  ~/.npmrc'
alias .claude.json='$EDITOR -n  ~/.claude.json'
alias nvimconfig='$EDITOR ~/.config/nvim/init.lua'
alias sshconfig='$EDITOR -n  ~/.ssh/config'
alias .aliases='$EDITOR -n  ~/.aliases'
alias hosts='$EDITOR -n  /private/etc/hosts'
alias php.ini='$EDITOR -n  /private/etc/php.ini'
alias .gitignore_global='$EDITOR -n  ~/.gitignore_global'
alias .gitconfig='$EDITOR -n  ~/.gitconfig'
alias .gitconfig_local='$EDITOR -n  ~/.gitconfig_local'
alias .claude='$EDITOR -n  ~/.claude'
alias network-sharing='sudo $EDITOR -n /etc/bootpd.plist'
alias dnsmasq.conf='$EDITOR -n ${HOMEBREW_PREFIX}/etc/dnsmasq.conf'
alias vscode-settings='code -n "$HOME/Library/Application Support/Code/User/settings.json"'

# 🤖 Android
alias android-inspector='adb forward tcp:9222 localabstract:chrome_devtools_remote'
alias adb-logcat='adb logcat browser:IEW "*:S"'

# 📦 Compression
alias tarls='tar -tf'
alias tgz='tar -czf'
alias untar='tar -vxf'
alias untgz='tar -vzxf'

# 👀 Quicklook
alias klook='qlmanage -p'

# 🧶 Yarn
alias yarn-check='yarn upgrade-interactive --latest'
alias npms='npm run start'
alias npmd='npm run dev'
alias npmp='npm publish'

# 🚀 Utilities
alias c='code .'
alias oc='opencode'
alias aicc='ai-conventional-commit'
alias about='fastfetch'
alias lg='lazygit'
alias ns='node-system'
alias runtimes='mise current'
alias dns-flush='sudo killall -HUP mDNSResponder'
alias shell-reload='exec $SHELL'
alias gem-back='gem pristine --all --only-executables'
alias allo='ping 8.8.8.8'
alias dl='curl -O'
alias wt='webtorrent --vlc --not-on-top download'
alias vim='nvim'
alias e='${(z)VISUAL:-${(z)EDITOR}}'
alias p='${(z)PAGER}'
alias type='type -a'
alias pbc='pbcopy'
alias pbp='pbpaste'
alias rubbish='trash'
alias litter='trash'
alias fix-cursor='echo -e "\e[6 q"'
alias cilogs='jenkins logs $(gh pr checks --json name,link,state -q ".[] | select(.name == \"default\") | .link") -f'

# 🤖 AI
alias explain='ai explain'
alias gca='git add . && git aicommit'
alias gcap='git add . && git aicommit && git push'
alias cld='claude'
alias cldc='claude --continue'
alias cldr='claude --resume'
alias cld-restart='claude-restart'
alias cldu='brew upgrade claude-code'

# 🧠 Basic Memory (disabled)
# alias note="basic-memory tools write-note"
# alias search="basic-memory tools search-notes --query"
# alias recent="basic-memory tools recent-activity"

# 🐙 GH aliases
alias prw='gh prw'

# 🚫 No Correct
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias cp='nocorrect cp'
alias ln='nocorrect ln'

# 🚫 No Glob
# Prevents zsh from expanding glob patterns (* ? [ ]) in command arguments
# This is useful for commands that handle their own pattern matching or when
# you want to pass literal patterns without shell expansion
alias npm='noglob npm'
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'
