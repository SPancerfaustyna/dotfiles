# Shell setup
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook
zmodload zsh/datetime

# Symbols
typeset -g THICK_MINUS=$'\U000f1639'		# 󱘹
typeset -g THICK_RIGHT_ARROW=$'\U000f0055'	# 󰁕
typeset -g TOP_RIGHT_CORNER=$'\u2517'		# ┗
typeset -g END_RIGHT_ARROW=$'\uE0B0'		# 
typeset -g CHECKMARK=$'\ue63f'			# 
typeset -g FAILMARK=$'\uf00d'			# 
typeset -g UP_ARROW=$'\U000f005d'
typeset -g DOWN_ARROW=$'\U000f0045'
typeset -g UP_DOWN_ARROW=$'\U000f0e79'
typeset -g LOCK=$'\uf023'
typeset -g SEARCH_ICON=$'\ue68f'
typeset -g DENIED=$'\U000f073a'
typeset -g TRASHCAN=$'\uf1f8'
typeset -g QUESTIONMARK=$'\uf128'

typeset -g GIT_SYMBOL=$'\uf418'

# Settings
# Hostname segment display
typeset -gi FORCE_SHOW_EXITCODE=${FORCE_SHOW_EXITCODE:-0}
typeset -gi REPLACE_OTHER_EXITCODE_WITH_SYMBOL=${REPLACE_OTHER_EXITCODE_WITH_SYMBOL:-1}
typeset -gi FORCE_SHOW_HOSTNAME_SEGMENT=${FORCE_SHOW_HOSTNAME_SEGMENT:-0}
typeset -gi SHOW_COMMIT_AGE=${SHOW_COMMIT_AGE:-1}
typeset -gi SHOW_DIRTY_MARKER=${SHOW_DIRTY_MARKER:-1}

typeset -gi SHOW_EXITCODE_SEGMENT=${SHOW_EXITCODE_SEGMENT:-1}
typeset -gi SHOW_HOSTNAME_SEGMENT=${SHOW_HOSTNAME_SEGMENT:-1}
typeset -gi SHOW_DIR_SEGMENT=${SHOW_DIR_SEGMENT:-1}
typeset -gi SHOW_GIT_SEGMENT=${SHOW_GIT_SEGMENT:-1}

promptSetting() {
	local setting=$1
	local action=$2
	local variable

	case $setting in
		forceExitcode)
			variable=FORCE_SHOW_EXITCODE
			;;
		replaceOtherExitcode)
			variable=REPLACE_OTHER_EXITCODE_WITH_SYMBOL
			;;
		forceHostname)
			variable=FORCE_SHOW_HOSTNAME_SEGMENT
			;;
		commitAge)
			variable=SHOW_COMMIT_AGE
			;;
		dirtyMarker)
			variable=SHOW_DIRTY_MARKER
			;;
		exitcode)
			variable=SHOW_EXITCODE_SEGMENT
			;;
		hostname)
			variable=SHOW_HOSTNAME_SEGMENT
			;;
		dir)
			variable=SHOW_DIR_SEGMENT
			;;
		git)
			variable=SHOW_GIT_SEGMENT
			;;
		*)
			print -u2 -- "Unknow prompt setting: $setting"
			return 1
			;;
	esac

	case $action in
		enable|on)
			typeset -g "$variable=1"
			;;
		disable|off)
			typeset -g "$variable=0"
			;;
		toggle)
			local current=${(P)variable}
			typeset -g "$variable=$(( ! current ))"
			;;
		status)
			local value
			if (( ${(P)variable} )); then
				value="true"
			else
				value="false"
			fi
			print -r -- "$setting: $value"
			;;
		*)
			print -u2 -- "Usage: promptSetting <dir|hostname> <enable|disable|toggle|status>"
			return 1
			;;
	esac

}

# Build prompt	
typeset -g COMMAND_PROMPT="%F{16}${THICK_MINUS}${THICK_RIGHT_ARROW} %f"

_formatCommitAge() {
	local -i milliseconds=$1

	if (( milliseconds < 1000 )); then
		REPLY="${milliseconds}"
	elif (( milliseconds < 60000 )); then
		REPLY="$(( milliseconds / 1000 ))s"
	elif (( milliseconds < 3600000 )); then
		REPLY="$(( milliseconds / 60000 ))m"
	elif (( milliseconds < 86400000 )); then
		REPLY="$(( milliseconds / 3600000 ))h"
	elif (( milliseconds < 2592000000 )); then
		REPLY="$(( milliseconds / 86400000 ))d"
	elif (( milliseconds < 31536000000 )); then
		REPLY="$(( milliseconds / 2592000000 ))mo"
	else
		REPLY="$(( milliseconds / 31536000000 ))y"
	fi
}

_buildGitSegment() {
	local branch
	local commitTimestamp
	local commitAge
	local behind
	local ahead
	local symbol
	local dirtyMarker=""

	branch=$(git branch --show-current 2>/dev/null)

	if [[ -z $branch ]]; then
		branch="@$(git rev-parse --short HEAD 2>/dev/null)"
	fi

	commitTimestamp=$(git log -1 --format=%ct 2>/dev/null)

	if [[ -n $commitTimestamp ]] && (( SHOW_COMMIT_AGE )); then
		local commitAgeMs=$(( (EPOCHSECONDS - commitTimestamp) * 1000 ))
		_formatCommitAge "$commitAgeMs"
		commitAge="${REPLY} "
	fi

	read -r behind ahead <<< "$( git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null )"

	if (( ahead > 0 && behind > 0 )); then
		symbol="${UP_DOWN_ARROW}"
	elif (( ahead > 0 )); then
		symbol="${UP_ARROW}"
	elif (( behind > 0 )); then
		symbol="${DOWN_ARROW}"
	else
		symbol="${GIT_SYMBOL}"
	fi

	if [[ -n $(git status --porcelain 2>/dev/null) ]] && (( SHOW_DIRTY_MARKER )); then
		dirtyMarker="*"
	fi

	REPLY="${commitAge}${symbol} ${branch}${dirtyMarker}"
}

_buildPrompt() {
	local lastStatus=$?

	local beginningOfSegment
	local endOfSegment
	
	local exitCodeSegment
	local -i canDrawExitCode=1
	local hostnameSegment
	local dirSegment
	local gitSegment
	local commandDurationSegment

	beginningOfSegment="%K{16}%F{17}${END_RIGHT_ARROW} "
	endOfSegment=" %f%k%K{17}%F{16}${END_RIGHT_ARROW}%f%k"

	# Set exit code segment
	exitCodeSegment="%K{16}%F{17} "
	
	case $lastStatus in

# 󰌾󰍉󰜺󰆴?

		0)	# success
			exitCodeSegment+="${CHECKMARK}"
			;;
		1)	# general failure
			exitCodeSegment+="${FAILMARK}"
			;;
		126)	# found, but not executable
			exitCodeSegment+="${LOCK}"
			;;
		127)	# command not found
			exitCodeSegment+="${SEARCH_ICON}"
			;;
		130)	# interrupted with Ctrl+C
			exitCodeSegment+="${DENIED}"
			;;
		137)	# killed, often SIGKILL
			exitCodeSegment+="${TRASHCAN}"
			;;
		*)	# otther/fallback
			if (( REPLACE_OTHER_EXITCODE_WITH_SYMBOL )); then
				exitCodeSegment+="${QUESTIONMARK}"
			else
				canDrawExitCode=0
				exitCodeSegment+="${lastStatus}"
			fi
			;;
	esac
	if (( canDrawExitCode )) && (( FORCE_SHOW_EXITCODE )); then
		exitCodeSegment+=" ${lastStatus}"
	fi


	exitCodeSegment+="${endOfSegment}"


	# Set hostname segment
	if (( SHOW_HOSTNAME_SEGMENT )) && { [[ -n $SSH_CONNECTION ]] || (( FORCE_SHOW_HOSTNAME_SEGMENT )) }; then
		hostnameSegment="${beginningOfSegment}%n@%m${endOfSegment}"
	else
		hostnameSegment=""
	fi

	# Set dir segment
	if (( SHOW_DIR_SEGMENT )); then
		dirSegment="${beginningOfSegment}%~${endOfSegment}"
	else
		dirSegment=""
	fi

	# Set git segment
	if (( SHOW_GIT_SEGMENT )) && git rev-parse --is-inside-work-tree &>/dev/null; then
		_buildGitSegment
		gitSegment="${beginningOfSegment}${REPLY}${endOfSegment}"
	else
		gitSegment=""
	fi
	
	# Set command durration segment

	PROMPT="
${exitCodeSegment}${hostnameSegment}${dirSegment}${gitSegment}%F{17}${END_RIGHT_ARROW}%f
${COMMAND_PROMPT}"

}

add-zsh-hook precmd _buildPrompt

PROMPT2='%F{16}${TOP_RIGHT_CORNER}${THICK_RIGHT_ARROW}%f '

# Transient prompt
accept-line() {
	PROMPT=$COMMAND_PROMPT
	RPROMPT=''

	zle reset-prompt
	zle .accept-line
}

zle -N accept-line

_transientInterupt() {
	if zle; then
		PROMPT=$COMMAND_PROMPT
		RPROMPT=''

		zle reset-prompt
		zle .send-break
	else
		return 130
	fi
}

_enablePromptInteruptTrap() {
	trap '_transientInterupt' INT
}

_disablePromptInteruptTrap() {
	trap - INT
}

add-zsh-hook precmd _enablePromptInteruptTrap
add-zsh-hook preexec _disablePromptInteruptTrap
