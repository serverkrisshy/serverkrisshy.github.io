#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='lsd -aFh --group-dirs=first --color=always'
alias la='lsd -lAFh --group-dirs=first --color=always'
alias ll='lsd -lFh --group-dirs=first --color=always'
alias l='lsd -Fh --group-dirs=first --color=always'

alias grep='grep --color=always'
alias ipinfo='curl --verbose ipinfo.io'
alias oneone='warp-cli -vv connect'
alias zero='warp-cli -vv disconnect'


eval "$(starship init bash)"

PS1='[\u@\h \W]\$ '
