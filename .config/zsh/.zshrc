# .zshrc

export GPG_TTY=$(tty)

# essentially syncs history between shells
setopt INC_APPEND_HISTORY
# when adding a new entry to history remove any currently present duplicate
setopt HIST_IGNORE_ALL_DUPS
# don't record lines starting with a space in the history
setopt HIST_IGNORE_SPACE

HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/.histfile
HISTSIZE=10000
SAVEHIST=10000

# disable ctrl-S/ctrl-Q for START/STOP
stty -ixon -ixoff

export EDITOR="/usr/bin/vim"
export NNN_USE_EDITOR=1          # use the $EDITOR when opening text files
export NNN_CONTEXT_COLORS="5132" # use a different color for each context
export NNN_TRASH=1               # trash (needs trash-cli) instead of delete

# add completion functions from zsh-completions packages to fpath so compinit
# can find them
#fpath=(/usr/share/zsh/site-functions $fpath)
#fpath=(${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions $fpath)
## initialize completions
#autoload -Uz compinit
#zstyle ':completion:*' menu select
#zmodload zsh/complist
#compinit
## allow completion of hidden files
#_comp_options+=(globdots)

# intialize autosuggestions plugin with base01 as color and ctrl-N to accept
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^n' autosuggest-accept

eval "$(zoxide init --cmd j zsh)" # initalize jump
source $ZDOTDIR/aliases.zsh       # load aliases
source $ZDOTDIR/man.zsh           # get colorful man pages with less
