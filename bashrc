
# User dependent .bashrc file
if [ -f ~/.bashrc ]
then
	. ~/.bashrc
fi

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return
# Use case-insensitive filename globbing
 shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
 shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
 shopt -s cdspell

# Completion options
 alias rm='rm -i'
 alias cp='cp -i'
 alias mv='mv -i'
 alias df='df -h'
 alias du='du -h'
 alias less='less -r'                          # raw control characters
 alias whence='type -a'                        # where, of a sort
 alias grep='grep --color'                     # show differences in colour
 alias egrep='egrep --color=auto'              # show differences in colour
 alias fgrep='fgrep --color=auto'              # show differences in colour
 alias ll='ls -ltrhF --color=auto'                 # classify files in colour
 alias la='ls -lAtrh'                              # all but . and ..
 alias c='clear'
 alias t='tput cup 23 0 && tput ed'
 alias h='history'
 alias b='bash --rcfile /tmp/.bashrc_temp_ST'

 export PATH=$PATH:/usr/lpp/mmfs/bin:/opt/sas/scripts:/opt/sas/sas_control/scripts:

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
 umask 022

case ${TERM} in
        xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
                PROMPT_COMMAND=${PROMPT_COMMAND}
                ;;
        screen*)
#                PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
  			screen_set_window_title () 
			{
				local HPWD=$(hostname -s)
				local HPWD=${HPWD/363748}
				printf '\ek%s\e\\' ${HPWD}@${USER}
			}
			PROMPT_COMMAND="screen_set_window_title; $PROMPT_COMMAND"
                ;;
esac
# sanitize TERM:
safe_term=${TERM//[^[:alnum:]]/?}
match_lhs=""

[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] \
        && type -P dircolors >/dev/null \
        && match_lhs=$(dircolors --print-database)

if [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] ; then

        # we have colors :-)

        # Enable colors for ls, etc. Prefer ~/.dir_colors
        if type -P dircolors >/dev/null ; then
                if [[ -f ~/.dir_colors ]] ; then
                        eval $(dircolors -b ~/.dir_colors)
                elif [[ -f /etc/DIR_COLORS ]] ; then
                       eval $(dircolors -b /etc/DIR_COLORS)
                fi
        fi
fi

#Set Environment
sl_host=$(hostname -s|sed 's/[0-9]*//g'|sed 's/.\{2\}$//')
op_host=$(hostname -s|sed 's/[0-9]*//g')
if [[ "$sl_host" == "lp" ]] || [[ "$sl_host" == "vp" ]] || [[ "$op_host"  == "frup" ]];
then
	export ENV_SYS=prod;
elif [[ "$sl_host" == "ln" ]] || [[ "$sl_host" == "vn" ]] || [[ "$op_host" == "frun" ]];
then
	export ENV_SYS=non-prod;
fi

#Set Cloud information
if [[ "$sl_host" == "lp" ]] || [[ "$sl_host" == "vp" ]] || [[ "$sl_host" == "ln" ]] || [[ "$sl_host" == "vn" ]];
then
	export ENV_CLD=SL;
	 alias irt='dzdo -i bash --rcfile /tmp/.bashrc_temp_ST'
	 alias isas='dzdo su - sas  bash --rcfile /tmp/.bashrc_temp_ST'
	 alias icas='dzdo su - cas  bash --rcfile /tmp/.bashrc_temp_ST'
	 alias isrv='dzdo su - srv-sas bash --rcfile /tmp/.bashrc_temp_ST'

elif [ "$op_host" == "frun" ] ||[ "$op_host" == "frup" ]
then
	export ENV_CLD=OP
	alias sunp='sudo -u sas-np bash --rcfile /tmp/.bashrc_temp_ST'
	alias sugpfs='sudo su - gpfsadmin bash --rcfile /tmp/.bashrc_temp_ST'
	alias sulsfnp='sudo -u lsf-np  bash --rcfile /tmp/.bashrc_temp_ST'
	alias susas='sudo -u srv-sas  bash --rcfile /tmp/.bashrc_temp_ST'
	alias sulsf='sudo -u lsfadmin  bash --rcfile /tmp/.bashrc_temp_ST'
	alias cd_scripts='cd /opt/sas/sas_control/scripts'
	alias odbc='cd /opt/sas/sas_control/install/AccessClients/9.4/SQLServer/'
	# Go to directory for sas.servers
	alias lev1='cd /opt/sas/sas_control/config/Lev1'
	# # VA metadata server - frup6779
	alias lev_va='cd /opt/sas/VA/config/Lev1'
	alias lev2='cd /opt/sas/sas_control/config_sbx/Lev2'
	alias lev_mid='cd /opt/sas/sas_mid/config/Lev1'
	alias mysandbox='cd /sas/data/EDWKDP/sharedsandbox/u1vc1350'

fi

#Set PS
PS1="$(echo ' \[\033[01;31m\]\u') $(echo '\[\033[01;36m\]@')$(echo '\[\033[01;32m\] [[${ENV_CLD}-${ENV_SYS}]]') $(echo '\[\033[01;31m\]\h - ')$(echo '\[\033[01;37m\]\w')\$\[\033[36m\]\n ==>\n ==>  "
PS2="> "
PS3="> "
PS4="+ "
if [[ "$TERM" == screen* ]] ; then
  screen_set_window_title () {
    local HPWD=$(hostname -s)
    local HPWD=${HPWD/363748}
    printf '\ek%s\e\\' ${HPWD}@${USERNAME}
  }
  PROMPT_COMMAND="screen_set_window_title; $PROMPT_COMMAND"
fi

function myssh() {
        chk_sl=$(echo $1|grep 363748)
        chk_fqdn=$(echo $1|grep geicoddc)
	chk_user=$(echo "$USER $USERNAME"|grep -i u1vc1350)
        if [[ -n $chk_sl ]] && [[ -n $chk_fqdn ]] && [[ -n $chk_user ]]
        then
                serv="$1";
                user=u1vc1350p;
	elif [[ -n $chk_sl ]] && [[ -n $chk_fqdn ]] && [[ -z $chk_user ]]
	then
		serv="$1";
		user=$USER;
        elif [[ -n $chk_sl ]] && [[ -z $chk_fqdn ]] && [[ -n $chk_user ]]
        then
                serv="${1}.geicoddc.net";
                user=u1vc1350p;
	elif [[ -n $chk_sl ]] && [[ -z $chk_fqdn ]] && [[ -z $chk_user ]]
	then
		serv="${1}.geicoddc.net";
		user=$USER;
        elif [[ -z $chk_sl ]] && [[ -z $chk_fqdn ]] ||[[ $# -ge 1 ]]
        then
                serv="${1}.geico.net";
                user=u1vc1350;
        elif [ $# -eq 0 ]
        then
                exit
        fi
        if [ $# -eq 1 ]
        then
		if [ -f ~/.mybashrc ]
		then
                scp -q -o StrictHostKeyChecking=no ~/.mybashrc $user@$serv:/tmp/.bashrc_temp_ST
		elif [ -f /tmp/.bashrc_temp_ST ]
		then
		scp -q -o StrictHostKeyChecking=no /tmp/.bashrc_temp_ST $user@$serv:/tmp/.bashrc_temp_ST
		fi
                ssh -q -t -o StrictHostKeyChecking=no $user@$serv "bash --rcfile /tmp/.bashrc_temp_ST; rm /tmp/.bashrc_temp_ST"
        elif [ $# -eq 2 ]
        then
        ssh -q -t -o StrictHostKeyChecking=no $user@$serv "$2"
        fi
}

function myscp() {
        chk_sl=$(echo $1|grep 363748)
        chk_fqdn=$(echo $1|grep geicoddc)
	chk_user=$(echo "$USER $USERNAME"|grep -i u1vc1350)
        scpfile="$2"
        if [[ -n $chk_sl ]] && [[ -n $chk_fqdn ]] && [[ -n $chk_user ]] 
        then
                serv="$1";
                user=u1vc1350p;
	elif [[ -n $chk_sl ]] && [[ -n $chk_fqdn ]] && [[ -z $chk_user ]]
	then
		serv="$1";
		user=$USERNAME;
        elif [[ -n $chk_sl ]] && [[ -z $chk_fqdn ]] && [[ -n $chk_user ]]
        then
                serv="${1}.geicoddc.net";
                user=u1vc1350p;
	elif [[ -n $chk_sl ]] && [[ -z $chk_fqdn ]] && [[ -z $chk_user ]]
	then
		serv="${1}.geicoddc.net";
		user= $USERNAME
        elif [[ -z $chk_sl ]] && [[ -z $chk_fqdn ]]
        then
                serv="${1}";
                user=u1vc1350;
        elif [ $# -lt 2 ] || [ "$1" -eq "-h" ] || [ $# -gt 3 ]
        then
                echo "Usage: myscp {destination server} {file to scp}  {destiantion location}";
                echo "If no destination location is provided default is your home directory on destination server ";
                exit;
        fi
        if [ $# -eq 2 ]
        then
                scp -q -o StrictHostKeyChecking=no $scpfile $user@$serv:~
        elif [ $# -eq 3 ]
        then
                scpdest="$3"
                scp -q -o StrictHostKeyChecking=no $scpfile $user@$serv:$scpdest
        fi
}

export ansible='363748vp42vy001'
if [ -f /opt/sas/lsf/conf/profile.lsf ]; then
	source /opt/sas/lsf/conf/profile.lsf
fi

alias desk='cd /mnt/c/Users/u1vc1350/Desktop/'
