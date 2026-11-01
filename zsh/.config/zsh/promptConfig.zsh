# ===========
#   SYMBOLS  
# ===========

typeset -g _SYMBOL_NEW_LINE=$'\n'

typeset -g SYMBOL_PROMPT_COMMAND_START=$'\U000F1639'	# 󱘹
typeset -g SYMBOL_PROMPT2_COMMAND_START=$'\U00002517'	# ┗
typeset -g SYMBOL_COMMAND_END=$'\U000F0055'				# 󰁕

typeset -g SYMBOL_LEFT_SEPERATOR=$'\U0000E0B0'			# 
typeset -g SYMBOL_RIGHT_SEPERATOR=$'\U0000E0B2'			# 

typeset -g SYMBOL_PROMPT_PADDING=$'='

# ==========
#   COLORS
# ==========

typeset -g COLOR_DEFAULT_FOREGROUND="#270112"
typeset -g COLOR_DEFAULT_BACKGROUND="#B85D87"

typeset -g COMMAND_PROMPT_PREFIX="%F{${COLOR_DEFAULT_BACKGROUND}}${SYMBOL_PROMPT_COMMAND_START}${SYMBOL_COMMAND_END}%f "
typeset -g COMMAND_PROMPT2_PREFIX="%F{${COLOR_DEFAULT_BACKGROUND}}${SYMBOL_PROMPT2_COMMAND_START}${SYMBOL_COMMAND_END}%f "
#COMMAND COLOR

# ==========
#   LAYOUT
# ==========

typeset -gi LAYOUT_COMMAND_ON_NEW_LINE=1
typeset -gi LAYOUT_EXTRA_SPACE_PROMPT=1

typeset -ga LAYOUT_LEFT_SEGMENTS_ORDER=(
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

typeset -ga LAYOUT_RIGHT_SEGMENTS_ORDER=(
	commandDuration
	date
)



