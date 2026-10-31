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

typeset -g COLOR_DEFAULT_FOREGROUND=""
typeset -g COLOR_DEFAULT_BACKGROUND=""

typeset -g COLOR_PROMPT_COMMAND_PREFIX=""
typeset -g COLOR_PROMPT2_COMMAND_PREFIX=""
#COMMAND COLOR

# ==========
#   LAYOUT
# ==========

typeset -gi LAYOUT_COMMAND_ON_NEW_LINE=1
typeset -gi LAYOUT_EXTRA_SPACE_PROMPT=1

typeset -ga LAYOUT_LEFT_SEGMENTS_ORDER=(
	exitcode
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



