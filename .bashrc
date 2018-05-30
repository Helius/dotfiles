# ~/.bashrc: executed by bash(1) for non-login shells. see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
#export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth:erasedups
# ignore come commands in history
export HISTIGNORE="git commit:ls:cd:exit:git reset*:ll" 

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=1000000000
HISTSIZE=1000000

# up and down arrows search history backward or forward
bind '"\e[A"':history-search-backward
bind '"\e[B"':history-search-forward

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# correct minor errors in the spelling of a directory component in a cd command
shopt -s cdspell
# save all lines of a multiple-line command in the same history entry (allows easy re-editing of multi-line commands)
shopt -s cmdhist

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; 
# turned off by default to not distract the user: the focus in a terminal window 
# should be on the output of commands, not on the prompt
force_color_prompt=yes

#if [ -n "$force_color_prompt" ]; then
#    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#	    color_prompt=yes
#    else
#    	color_prompt=
#    fi
#fi

#case `id -u` in
#    0)  lcolor='\[\e[01;31m\]';;
#    *)  lcolor='\[\e[02;32m\]';;
#esac
#hcolor='\[\e[02;33m\]'
#nocolor='\[\e[0m\]'

#if [ "$color_prompt" = yes ]; then
#	PS1='\e[0;31m\]\u:\e[0m\]\e[0;34m\]\w \e[0;31m\]$ \e[0m\] '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    
    alias tree='tree -AC --dirsfirst'
fi

# some more ls aliases
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Запрещающие настройки:
shopt -u mailwarn
unset MAILCHECK         # чтобы командная оболочка не сообщала о прибытии почты

#--------------
# some functions

function git_diff() {
	  #git diff --no-ext-diff -w "$@" | vim -R -
	  git diff --no-ext-diff -w "$@" 
}

function svn_diff() {
	  #git diff --no-ext-diff -w "$@" | vim -R -
	  svn diff | vim -R -
}

function git_log {
#	git log --graph --full-history --all --color --date=short --date=relative --date-order --pretty=format:"%x1b[33m%h%x09%x09%x1b[34m%ad%x09%an%x1b[32m%d%x1b[0m%x1b[0m%x09%s" "$@"
	git log --graph --full-history --color --date=short --date=relative --date-order --pretty=format:"%x1b[33m%h%x09%x09%x1b[34m%ad%x09%an%x1b[32m%d%x1b[0m%x1b[0m%x09%s" "$@"
}
#---------------
# Prompt
#---------------
# следим за кол-вом вложений баш и если больше 1го добавляем счетчик в начало промпта
if [[ "$SHLVL" -gt "1" ]]; then
	NEST_CNT="["$(($SHLVL-1))"]"
else
	NEST_CNT=""
fi

if [[ "${DISPLAY#$HOST}" != ":0.0" &&  "${DISPLAY}" != ":0" ]]; then
	PS1='\[\e[7;32m\]$NEST_CNT\[\e[0;32m\]\[\e[7;31m\]\u\[\e[0;32m\]:\[\e[0m\]\[\e[0;34m\]\w \[\e[35m\][:`git branch 2>/dev/null | grep "*" | cut -c3-`] \[\e[0;31m\]$ \[\e[0m\] '
else
	PS1='\[\e[7;31m\]$NEST_CNT\[\e[0;32m\]\[\e[7;32m\]\u\[\e[0;32m\]:\[\e[0m\]\[\e[0;34m\]\w \[\e[35m\][:`git branch 2>/dev/null | grep "*" | cut -c3-`] \[\e[0;32m\]$ \[\e[0m\] '
fi

export EDITOR=/usr/bin/vim
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.bin" ] ; then
  PATH="$HOME/.bin:$PATH"
fi

# ignore case at completion cd dro -> cd Dropbox
echo 'set completion-ignore-case on' > ~/.inputrc

source .local_exports
