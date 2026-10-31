# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=12000
SAVEHIST=10000
setopt beep nomatch
unsetopt autocd extendedglob
bindkey -v
# End of lines configured by zsh-newuser-install

# Do not save duplicate commands next to each other
setopt HIST_IGNORE_DUPS

# Append history instead of relplacing it
setopt APPEND_HISTORY

# Share history between open zsh sessions
setopt SHARE_HISTORY

# Enable completion
autoload -Uz compinit
compinit

# 	Prompt
source "$HOME/.config/zsh/prompt.zsh"

export PATH="$HOME/.local/bin:$PATH"
