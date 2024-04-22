##==bashrc

# If not running interactively, don't do anything (regex requires [[ ]].)
[[ $- != *i* ]] && return

#_set_my_PS1() {
#    PS1='[\u@\h \W]\$ '
#    if [ "$(whoami)" = "liveuser" ] ; then
#        local iso_version="$(grep ^VERSION= /etc/os-release | cut -d '=' -f 2)"
#        if [ -n "$iso_version" ] ; then
#            local prefix="eos-"
#            local iso_info="$prefix$iso_version"
#            PS1="[\u@$iso_info \W]\$ "
#        fi
#    fi
#}
#
#_set_my_PS1
#unset -f _set_my_PS1

test "$(whoami)" = "root" && return

# limits recursive functions, see 'man bash'
test -z "${FUNCNEST}" && export FUNCNEST=100

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

#------------------------------------------------------------

## Aliases for the functions above.
## Uncomment an alias if you want to use it.
##

# alias ef='_open_files_for_editing'     # 'ef' opens given file(s) for editing
################################################################################

# workaround https://github.com/NixOS/nix/issues/1056
if test -n "$IN_NIX_SHELL"; then
  export TERMINFO=/run/current-system/sw/share/terminfo
  # Reload terminfo
  real_TERM=$TERM; TERM=xterm; TERM=$real_TERM; unset real_TERM
fi

##==aliases_and_commontools
source "$HOME/dotfiles/.config/shells/bash_aliases"
source "$HOME/dotfiles/.config/shells/aliases"
source "$HOME/dotfiles/.config/shells/aliases_git"

##==wayland_exports
if test "$XDG_SESSION_TYPE" = 'wayland'
then
  export QT_QPA_PLATFORM='wayland'
  export CLUTTER_BACKEND='wayland'
  #export GDK_BACKEND='wayland' # breaks Electron based apps
fi

##==rubygems is annoying to setup
# export GEM_HOME="$HOME/.local/gems"
# export GEM_PATH="$HOME/.local/share/gem/ruby/3.0.0/bin"
# PATH=${PATH}:"$HOME/.local/gems"
# PATH=${PATH}:"$GEM_PATH"

##==PATH
PATH=${PATH}:"$HOME/.cargo/bin"
PATH=${PATH}:"$HOME/.local/bin"
PATH=${PATH}:"$HOME/.local/appimages"
# PATH=${PATH}:"$HOME/dev/git/cpp/kakoune/libexec/kak"
# PATH=${PATH}:"$HOME/dev/git/zi/zig/master/build" # zig stages 1,2
# PATH=${PATH}:"$HOME/dev/git/zi/zig/master/build/stage3/bin" # zig stages 3
# PATH=${PATH}:"$HOME/dev/git/zi/zig/master/buildrel/stage3/bin" # zig stages 3
PATH=${PATH}:"$HOME/dev/zdev/zig/master/rel/bin/"
PATH=${PATH}:"$HOME/.luarocks/bin"
PATH=${PATH}:"$HOME/.local/nvim/bin" # neovim testing
# PATH=${PATH}:"$HOME/dev/git/zi/zigmod/zig-out/bin" # zigmod binary

#testing www.ziglang.org
#PATH=${PATH}:"$HOME/src/zig-doctest/zig-cache/bin"
#PATH=${PATH}:"$HOME/src/hugo"

##==ssh
# there is no very reliable and simple other way to have ssh agent running
#eval "$(ssh-agent -s)"
#trap "kill ${SSH_AGENT_PID}" exit
#trap "ssh-agent -k" exit
#export VISUAL="nvim"
export EDITOR="nvim"

##==gpg
#export GPG_TTY="$(tty)"
#export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
#gpgconf --launch 'gpg-agent'
#trap 'gpgconf --kill gpg-agent' exit
# Problem sign_and_send_pubkey: signing failed for ED25519 PRIVATE_KEY_PATH from agent: agent refused operation
# gpg-connect-agent updatestartuptty /bye >/dev/null

# Note: Other shells do not know what gpg server is currently attached to.

# start gpg with ssh to workaround pinentry-tty bugs
startGpg() {
  gpgconf --launch 'gpg-agent'
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
}
# reconnect to gpg client to workaround pinentry-tty bugs
reconnectGpg() {
  gpg-connect-agent updatestartuptty /bye >/dev/null
}
# stop gpg with ssh to workaround pinentry-tty bugs
stopGpg() {
  gpgconf --kill gpg-agent
  unset -v GPG_TTY
  unset -v SSH_AUTH_SOCK
}
# fix gpg tty via stopping, starting and updating startup tty
fixGpg() {
  gpgconf --kill gpg-agent
  unset -v GPG_TTY
  unset -v SSH_AUTH_SOCK
  gpgconf --launch 'gpg-agent'
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpg-connect-agent updatestartuptty /bye >/dev/null
}

countdown() {
    start="$(( $(date '+%s') + $1))"
    while [ $start -ge $(date +%s) ]; do
        time="$(( $start - $(date +%s) ))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

stopwatch() {
    start=$(date +%s)
    while true; do
        time="$(( $(date +%s) - $start))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

export -f startGpg
export -f reconnectGpg
export -f stopGpg
export -f countdown
export -f stopwatch


##==quickjumper
eval "$(zoxide init bash)"
##==autoenv
eval "$(direnv hook bash)"

##==kitty
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
##==cargo
source "$HOME/.cargo/env"