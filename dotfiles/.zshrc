# history settings
HISTFILE=~/.history_zsh
HISTSIZE=100000
SAVEHIST=100000
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
#setopt share_history
# set terminal title
precmd () {print -Pn "\e]0;%n@%m: %d\a"}

# other basic settings
setopt auto_pushd
setopt pushd_ignore_dups
setopt extendedglob
unsetopt beep
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# bind keys
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# autocompletion
zstyle :compinstall filename '/home/james/.zshrc'

compdef mosh=ssh

# processes
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs \
        avahi-autoipd backup colord gnats hplip irc kernoops libuuid lightdm \
        list man messagebus proxy rtkit saned speech-dispatcher sys syslog usbmux \
        www-data

# this doesn't work :(
# zstyle ':completion:*:*:git:*' commands 'base'

# external files
source /etc/bash_completion.d/virtualenvwrapper
source /etc/zsh_command_not_found
source ~/.aliases
ZSH_THEME_GIT_PROMPT_NOCACHE=true
source ~/.zsh/git-prompt/zshrc.sh

# prompt
PROMPT='%F{blue}%~%f$(git_super_status)$ '
# if caching, call once to refresh for git on new terminal
#update_current_git_vars

# various exports
export EDITOR=vim
export GPGKEY=876302FC
export PATH=${PATH}:/usr/local/bin/:~/.bin/
export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_REQUIRE_VIRTUALENV=true
export _JAVA_AWT_WM_NONREPARENTING=1
export GDK_NATIVE_WINDOWS=true
export GOPATH=/home/james/code/mygo/
