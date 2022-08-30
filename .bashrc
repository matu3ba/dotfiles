## ~/.bashrc ##

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.welcome_screen ]] && . ~/.welcome_screen

_set_my_PS1() {
    PS1='[\u@\h \W]\$ '
    if [ "$(whoami)" = "liveuser" ] ; then
        local iso_version="$(grep ^VERSION= /etc/os-release | cut -d '=' -f 2)"
        if [ -n "$iso_version" ] ; then
            local prefix="eos-"
            local iso_info="$prefix$iso_version"
            PS1="[\u@$iso_info \W]\$ "
        fi
    fi
}
_set_my_PS1
unset -f _set_my_PS1

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

################################################################################
## Some generally useful functions.
## Consider uncommenting aliases below to start using these functions.

_open_files_for_editing() {
    # Open any given document file(s) for editing (or just viewing).
    # Note1: Do not use for executable files!
    # Note2: uses mime bindings, so you may need to use
    #        e.g. a file manager to make some file bindings.

    local progs="xdg-open exo-open"     # One of these programs is used.
    local prog
    for prog in $progs ; do
        if [ -x /usr/bin/$xx ] ; then
            $prog "$@" >& /dev/null &
            return
        fi
    done
    echo "Sorry, none of programs [$progs] is found." >&2
    echo "Tip: install one of packages" >&2
    for prog in $progs ; do
        echo "    $(pacman -Qqo "$prog")" >&2
    done
}

#------------------------------------------------------------

## Aliases for the functions above.
## Uncomment an alias if you want to use it.
##

# alias ef='_open_files_for_editing'     # 'ef' opens given file(s) for editing
################################################################################

#### USER alias ####
. $HOME/dotfiles/.config/shells/oh_aliases
. $HOME/dotfiles/.config/shells/bash_aliases
. $HOME/dotfiles/.config/shells/aliases
. $HOME/dotfiles/.config/shells/aliases_git

if [ $XDG_SESSION_TYPE == 'wayland' ] ; then
  export QT_QPA_PLATFORM='wayland'
  #export GDK_BACKEND='wayland' # breaks Electron based apps
  export CLUTTER_BACKEND='wayland'
fi

PATH=$PATH:"${HOME}/.cargo/bin"
PATH=$PATH:"${HOME}/.local/bin"
PATH=$PATH:"${HOME}/.local/appimages"
PATH=$PATH:"${HOME}/dev/git/cpp/kakoune/libexec/kak"
PATH=$PATH:"${HOME}/dev/git/zig/zig/master/build" # zig stages 0,1,2,3
PATH=$PATH:"${HOME}/.luarocks/bin"
PATH=$PATH:"${HOME}/.local/lua-language-server/bin"
PATH=$PATH:"${HOME}/.local/nvim/bin" # neovim testing
#PATH=$PATH:"${HOME}/dev/git/go/oh" # oh shell: nice introspection, but too slow
PATH=$PATH:"${HOME}/dev/git/zig/zigmod/zig-out/bin" # zigmod binary

#testing www.ziglang.org
#PATH=$PATH:"${HOME}"/src/zig-doctest/zig-cache/bin
#PATH=$PATH:"${HOME}"/src/hugo

# there is no very reliable and simple other way to have ssh agent running
#eval "$(ssh-agent -s)"
#trap "kill $SSH_AGENT_PID" exit
#trap "ssh-agent -k" exit
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch 'gpg-agent'
trap 'gpgconf --kill gpg-agent' exit

eval "$(zoxide init bash)" # quickjumper

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

alias luamake=/home/misterspoon/.local/lua-language-server/3rd/luamake/luamake
