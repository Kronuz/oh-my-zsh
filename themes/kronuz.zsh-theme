# # -*- sh -*- vim:set ft=sh ai et sw=4 sts=4:

function git_prompt_full() {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || \
	ref=$(git rev-parse --short HEAD 2> /dev/null) || return
	GIT_BRANCH=${ref#refs/heads/}

	# Get the status of the working tree
	INDEX=$(git status --porcelain -b 2> /dev/null)
	GIT_STATUS=""
	if $(echo "$INDEX" | grep -m 1 -E '^\?\? ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^A  ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$GIT_STATUS"
	elif $(echo "$INDEX" | grep -m 1 '^M  ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^ M ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$GIT_STATUS"
	elif $(echo "$INDEX" | grep -m 1 '^AM ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$GIT_STATUS"
	elif $(echo "$INDEX" | grep -m 1 '^ T ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^R  ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^ D ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$GIT_STATUS"
	elif $(echo "$INDEX" | grep -m 1 '^D  ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$GIT_STATUS"
	elif $(echo "$INDEX" | grep -m 1 '^AD ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^UU ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^## .*ahead' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^## .*behind' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$GIT_STATUS"
	fi
	if $(echo "$INDEX" | grep -m 1 '^## .*diverged' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$GIT_STATUS"
	fi
	GIT_STATUS="$(git_remote_status)$GIT_STATUS"
	if [[ -n $INDEX ]] && $(echo "$INDEX" | grep -m 1 -v -E '^\?\? ' &> /dev/null); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_DIRTY$GIT_STATUS"
	else
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_CLEAN$GIT_STATUS"
	fi
	if [[ -n $ZSH_THEME_GIT_PROMPT_STASHED ]] && $(git rev-parse --verify refs/stash >/dev/null 2>&1); then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$GIT_STATUS"
	fi
	if [ "$GIT_STATUS" != "" ]; then
		GIT_STATUS="$ZSH_THEME_GIT_PROMPT_STATUS_PREFIX$GIT_STATUS$ZSH_THEME_GIT_PROMPT_STATUS_SUFFIX"
	fi
	echo "$ZSH_THEME_GIT_PROMPT_PREFIX$GIT_BRANCH$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function prompt_color() {
	if [ -z "$ZSH_THEME_KRONUZ_PROMPT_COLOR" ]; then
		case $(hostname | tr "[:upper:]" "[:lower:]") in
			*$USERNAME*)
				ZSH_THEME_KRONUZ_PROMPT_COLOR=blue
				;;
			*)
				if [ -x /sbin/sysctl ] && [ "$(sysctl security.jail.jailed)" = "security.jail.jailed: 1" ]; then
					ZSH_THEME_KRONUZ_PROMPT_COLOR=green
				else
					ZSH_THEME_KRONUZ_PROMPT_COLOR=yellow
				fi
				;;
		esac
	fi
	if [ "$USERNAME" = "root" ]; then
		ZSH_THEME_KRONUZ_PROMPT_COLOR=red
	fi
	echo "$ZSH_THEME_KRONUZ_PROMPT_COLOR"
}

IP="$(/sbin/ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2;}')"
ZSH_THEME_KRONUZ_RETURN_CODE="%(?,%{$fg[green]%}%{•%G%},%{$fg[red]%}%{•%G%})%{$reset_color%}"
ZSH_THEME_KRONUZ_PROMPT_HOST="%{$reset_color%}%n%{$fg_bold[white]%}@%{$reset_color%}%{$fg[$(prompt_color)]%}$IP(%M)%{$fg[white]%}:%{$reset_color%}"
ZSH_THEME_KRONUZ_PROMPT_PATH="%{$fg_bold[$(prompt_color)]%}%~%{$reset_color%}"
ZSH_THEME_KRONUZ_PROMPT_END="%(!.%{$fg_bold[red]%}#.%{$fg_bold[white]%}$)%{$reset_color%}"
ZSH_THEME_KRONUZ_PROMPT_PREFIX="$ZSH_THEME_KRONUZ_RETURN_CODE%{$fg[$(prompt_color)]%}[%{$reset_color%}"
ZSH_THEME_KRONUZ_PROMPT_SUFFIX="%{$fg[$(prompt_color)]%}]%{$reset_color%}$ZSH_THEME_KRONUZ_PROMPT_END"
PROMPT='$ZSH_THEME_KRONUZ_PROMPT_PREFIX$ZSH_THEME_KRONUZ_PROMPT_HOST$ZSH_THEME_KRONUZ_PROMPT_PATH$(git_prompt_full)$ZSH_THEME_KRONUZ_PROMPT_SUFFIX '
RPROMPT="%(?..%{$fg[red]%}%?%{⏎%G%}%{$reset_color%})"

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[grey]%}git:(%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_STATUS_PREFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[grey]%})%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}%{✗%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg[magenta]%}%{⇿%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}%{⇽%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[green]%}%{⇾%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}%{❖%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[cyan]%}%{⼐%2G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}%{⊖%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[yellow]%}%{↹%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[red]%}%{✴%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}%{✛%G%}%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[grey]%}%{✫%G%}%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$fg[magenta]%}%{⇣%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$fg_bold[green]%}%{⇡%G%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="%{$fg[magenta]%}%{↕%G%}%{$reset_color%}"
