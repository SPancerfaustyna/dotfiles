# Shell setup
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook
zmodload zsh/datetime

# Symbols
typeset -g NEW_LINE=$'\n'

typeset -g PROMPT_COMMAND_START_SYMBOL=$'\U000F1639'
typeset -g PROMPT2_COMMAND_START_SYMBOL=$'\U0002517'
typeset -g COMMAND_END_SYMBOL=$'\U000F0055'
typeset -g LEFT_SEPARATOR=$'\uE0B0'
typeset -g RIGHT_SEPARATOR=$'\uE0B2'
typeset -g PROMPT_PADDING_SYMBOL='='

typeset -g DEFAULT_FOREGROUND="#270112"
typeset -g DEFAULT_BACKGROUND="#B85D87"
typeset -g PROMPT_BACKGROUND="#270112"
typeset -g PROMPT_PREFIX_FOREGROUND="#B85D87"

typeset -gi COMMAND_ON_NEW_LINE=1
typeset -gi EXTRA_SPACE_PROMPT=1
typeset -g PROMPT_COMMAND_PREFIX="%F{${PROMPT_PREFIX_FOREGROUND}}${PROMPT_COMMAND_START_SYMBOL}${COMMAND_END_SYMBOL}%f "
typeset -g PROMPT2_COMMAND_PREFIX="%F{${PROMPT_PREFIX_FOREGROUND}}${PROMPT2_COMMAND_START_SYMBOL}${COMMAND_END_SYMBOL}%f "

# Segment order
# hostname, git, durration, exitCode, directory, Text, project, battery, date, os?, terminal?,
typeset -ga PROMPT_LEFT_SEGMENTS=(
	exitCode
	hostname
	directory
	git
#	project
#	customText
#	battery
#	os
#	shell
)

typeset -ga PROMPT_RIGHT_SEGMENTS=(
	commandDuration
	date
)

typeset -gF COMMAND_START_TIME=0
typeset -gF COMMAND_DURATION=0

# Segment builders
_buildExitCodeSegment() {
	local lastStatus=$1
	reply=("$lastStatus")
}

_buildHostnameSegment() {
	reply=("%n@%m")
	SEGMENT_FOREGROUND="yellow"
	SEGMENT_BACKGROUND="black"
}

_buildDirectorySegment() {
	reply=("%~")
}

_buildGitSegment() {
	local branch
	git rev-parse --is-inside-work-tree &>/dev/null || {
		reply=()
		return
	}
	
	branch=$(git branch --show-current 2>/dev/null)

	if [[ -z $branch ]]; then
		branch="@$(git rev-parse --short HEAD 2>/dev/null)"
	fi

	reply=("$branch")
}

_buildProjectSegment() {
	reply=(
		"node"
		"python"
	)
	replyForeground[2]="yellow"
	replyBackground[2]="blue"
}

_buildCommandDurationSegment() {
	reply=("${COMMAND_DURATION}s") # Temp
}

_buildCustomTextSegment() {
	reply=("Text")
}

_buildBatterySegment() {
	reply=("100%%")
}

_buildDateSegment() {
	reply=("1-08-2026")
	SEGMENT_FOREGROUND="yellow"
	SEGMENT_BACKGROUND="black"
}

_buildOsSegment() {
	reply=("linux")
}

_buildShellSegment() {
	reply=("zsh")
}

# Segment builder dispatchers
_dispatchBuildSegment() {
	local name=$1
	local lastStatus=$2
	local -i index

	reply=()
	replyForeground=()
	replyBackground=()

	SEGMENT_FOREGROUND=$DEFAULT_FOREGROUND
	SEGMENT_BACKGROUND=$DEFAULT_BACKGROUND

	case $name in
		exitCode)			_buildExitCodeSegment "$lastStatus" ;;
		hostname)			_buildHostnameSegment ;;
		directory)			_buildDirectorySegment ;;
		git)				_buildGitSegment ;;
		project)			_buildProjectSegment ;;
		commandDuration)	_buildCommandDurationSegment ;;
		customText)			_buildCustomTextSegment ;;
		battery)			_buildBatterySegment ;;
		date)				_buildDateSegment ;;
		os)					_buildOsSegment ;;
		shell)				_buildShellSegment ;;
	esac

	for (( index = 1; index <= ${#reply}; index++ )); do
		[[ -n ${replyForeground[index]} ]] || replyForeground[index]=$SEGMENT_FOREGROUND

		[[ -n ${replyBackground[index]} ]] || replyBackground[index]=$SEGMENT_BACKGROUND
	done
}

# Segment collector
_collectSegments() {
	local lastStatus=$1
	shift # removes first argument

	local name

	local -a collectedText=()
	local -a collectedForeground=()
	local -a collectedBackground=()

	for name in "$@"; do
		_dispatchBuildSegment "$name" "$lastStatus"

		collectedText+=("${reply[@]}")
		collectedForeground+=("${replyForeground[@]}")
		collectedBackground+=("${replyBackground[@]}")
	done

	reply=("${collectedText[@]}")
	replyForeground=("${collectedForeground[@]}")
	replyBackground=("${collectedBackground[@]}")
}

# Segments renderers
_renderSegments() {
	local isRight=$1
	local textArrayName=$2
	local foregroundArrayName=$3
	local backgroundArrayName=$4

	local -a segmentsText=("${(@P)textArrayName}")
	local -a segmentsForeground=("${(@P)foregroundArrayName}")
	local -a segmentsBackground=("${(@P)backgroundArrayName}")

	local output=""
	local separator="${LEFT_SEPARATOR}"
	local -i width=0
	local -i index
	local -i count=${#segmentsText}

	if (( isRight && count != 0 )); then
		separator="${RIGHT_SEPARATOR}"
		output+="%F{${PROMPT_BACKGROUND}}${separator}"
		width+=1
	fi
	if (( ! isRight && count == 0 )); then
		output+="%F{${DEFAULT_BACKGROUND}}"
		output+="%K{${PROMPT_BACKGROUND}}"
		output+="${separator}"
		width+=1
	fi

	for (( index = 1; index <= count; index++ )); do
		local text=${segmentsText[index]}
		local foreground=${segmentsForeground[index]}
		local background=${segmentsBackground[index]}
		local expandedText="${(%)text}"

		if (( isRight )); then
			output+="%K{${PROMPT_BACKGROUND}}"
			output+="%F{${background}}"
			output+="${separator}"
			width+=1
		elif (( index != 1 )); then
			output+="%K{${background}}"
			output+="%F{${PROMPT_BACKGROUND}}"
			output+="${separator}"
			width+=1
		fi

		output+="%K{${background}}"
		output+="%F{${foreground}}"
		output+=" ${text} "
		width+=$(( ${#expandedText} + 2 ))

		if (( ! isRight )); then
			output+="%K{${PROMPT_BACKGROUND}}"
			output+="%F{${background}}"
			output+="${separator}"
			width+=1
		elif (( index != count )); then
			output+="%F{${PROMPT_BACKGROUND}}"
			output+="${separator}"
			width+=1
		fi

		output+="%f%k"
	done
	if (( ! isRight )); then
		output+="%f%k"
		output+="%F{${PROMPT_BACKGROUND}}"
		output+="${separator}"
		width+=1
	fi

	output+="%f%k"

	REPLY=$output
	REPLY_WIDTH=$width
}

_buildPadding() {
	local -i leftWidth=$1
	local -i rightWidth=$2
	local symbol=${3:-' '}

	local -i gap=$(( COLUMNS - leftWidth - rightWidth ))
	local padding

	if (( gap < 2 )); then
		REPLY=" "
	elif (( gap < 10 )); then
		gap+=-2
		printf -v padding '%*s' "$gap" ''
		padding=${padding// /$symbol}

		REPLY=" $padding "
	else 
		gap+=-4
		printf -v padding '%*s' "$gap" ''
		padding=${padding// /$symbol}

		REPLY="  ${padding}  "
	fi
}

# Main promp function
_buildPrompt() {
	local lastStatus=$1

	_collectSegments "$lastStatus" "${PROMPT_LEFT_SEGMENTS[@]}"
	
	local -a leftSegmentsText=("${reply[@]}")
	local -a leftSegmentsForeground=("${replyForeground[@]}")
	local -a leftSegmentsBackground=("${replyBackground[@]}")

	_collectSegments "$lastStatus" "${PROMPT_RIGHT_SEGMENTS[@]}"

	local -a rightSegmentsText=("${reply[@]}")
	local -a rightSegmentsForeground=("${replyForeground[@]}")
	local -a rightSegmentsBackground=("${replyBackground[@]}")

	_renderSegments 0 leftSegmentsText leftSegmentsForeground leftSegmentsBackground

	local leftPrompt=$REPLY
	local -i leftPromptWidth=$REPLY_WIDTH

	_renderSegments 1 rightSegmentsText rightSegmentsForeground rightSegmentsBackground

	local rightPrompt=$REPLY
	local -i rightPromptWidth=$REPLY_WIDTH

	PROMPT=""
	if (( EXTRA_SPACE_PROMPT )); then
		PROMPT+="${NEW_LINE}"
	fi

	if (( COMMAND_ON_NEW_LINE )); then
		_buildPadding "$leftPromptWidth" "$rightPromptWidth" "$PROMPT_PADDING_SYMBOL"
		local padding=$REPLY

		PROMPT+="${leftPrompt}"
		PROMPT+="%F{${PROMPT_BACKGROUND}}${padding}%f"
		PROMPT+="${rightPrompt}${NEW_LINE}${PROMPT_COMMAND_PREFIX}"
		RPROMPT=""
	else
		PROMPT+="${leftPrompt} "
		RPROMPT="${rightPrompt}"
	fi
}

PROMPT2=$PROMPT2_COMMAND_PREFIX
RPROMPT2=""

_calculateCommandDuration() {
	local -F commandEnd=$1
	
	if (( COMMAND_START_TIME > 0 && commandEnd > 0 )); then
		COMMAND_DURATION=$(( commandEnd - COMMAND_START_TIME ))
	else
		COMMAND_DURATION=0
	fi

	COMMAND_START_TIME=0
}

_recordCommandStart() {
	COMMAND_START_TIME=$EPOCHREALTIME
}

_transientAcceptLine() {
	PROMPT=$PROMPT_COMMAND_PREFIX
	RPROMPT=""

	zle reset-prompt
	zle .accept-line
}

zle -N accept-line _transientAcceptLine

_transientInterrupt() {
	if zle; then
		PROMPT="${PROMPT_COMMAND_PREFIX} no "
		RPROMPT=""

		zle reset-prompt
		zle .send-break
	else
		return 130
	fi
}

_enablePromptInterruptTrap() {
	trap '_transientInterrupt' INT
}

_disablePromptInterruptTrap() {
	trap - INT
}

_promptPrecmd() {
	local -i lastStatus=$?
	local -F commandEnd=$EPOCHREALTIME

	_calculateCommandDuration "$commandEnd"
	_buildPrompt "$lastStatus"
	_enablePromptInterruptTrap
}

_promptPreexec() {
	_disablePromptInterruptTrap
	_recordCommandStart
}

add-zsh-hook precmd _promptPrecmd

add-zsh-hook preexec _promptPreexec

