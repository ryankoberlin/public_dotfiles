#!/bin/bash

#####################################################################
##                                                                 ##
## Login identifier to manage when the bash environment is sourced ##
##                                                                 ##
#####################################################################

export EDITOR=vi
export VISUAL=vi

export PS1='\u@\H ${PWD} # '

# Checking parent Proc #
export PROCS=()
SCREEN=0

export PROCS=( $( ps -o ppid=$$ | uniq ) )

# while [[ ${#PROCS[@]} > 0 ]];
#  	do
#  		if ps faux | grep -q "${PROCS[0]}.*[s]u - $(whoami)"; then 
# 			echo "$(date) SU Login $0 PPID=$$" >> /home/$(whoami)/.login_log	
# 			## Not loading bash functions to keep the env clean for anyone using my user
#  			PROCS=()
#  		elif ps faux | grep -q ${PROCS[0]}.*[S]CREEN; then 
# 			if [[ $0 = "-bash" ]]; then
# 				echo "$(date) Screen Login; possible SU $0 PPID=$$" >> /home/$(whoami)/.login_log
# 			else
# 				echo "$(date) Screen Login $0 PPID=$$" >> /home/$(whoami)/.login_log
# 			fi
#  			SCREEN=1
#  			PROCS=()
#  		elif ps faux | grep -q "${PROCS[0]}.*[s]shd"; then 
# 			echo "$(date) SSH Login $0 PPID=$$" >> /home/$(whoami)/.login_log
# 			PROCS=()
#  			source ~/.init_bash
# #			screen -ls |sed '/Socket\ in/d;'
# 		else PROCS=("${PROCS[@]:1}")
#  	fi
# done
# 
# if [[ $SCREEN = 1 ]]; then
#  	source ~/.init_bash
# fi
alias load='source /home/$(whoami)/git/dotfiles/.init_bash; uptime'
