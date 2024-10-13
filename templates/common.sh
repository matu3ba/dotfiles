#!/usr/bin/env sh
# Posix examples largely compliant with bash shell.

set -e
CWD=$(pwd)
trap "cd ${CWD}" EXIT HUP INT QUIT TERM
# if SIGSEGV is included, then at least bash complains with 'trap: SIGSEGV: bad trap'

# unless commands return non-zero status, use
set -e
# temporary set
set +e
# and reset
set -e

# see https://unix.stackexchange.com/questions/520035/exit-trap-with-posix
# Using signal numbers as complete solution is not portable and listing all signal
# names is ugly/unreadable
CWD=$(pwd)
trap "cd ${CWD}" EXIT HUP INT QUIT SEGV TERM

wait 20 &
pid_wait=$!
kill $! # default SIGTERM
wait $!

# string/* is used verbatim without match and we dont have nullglob against that
# workaround with (extra case for symlinks)
# [ -e "$file" ] || [ -L "$file" ] || continue

# See also utilities:
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/
# filter: grep, sed, cat, printf, tr, xargs
# action: test, cd, ls, mkdir, rm, vi, diff
# system: jobs, kill, fg, chmod
# well: alias, unalias, awk, echo, cut, sort, head, tail, more, pwd, df, du,
#       find, cp, mv, rmdir, dirname, basename
# few: tee, uniq, bc, c99, cksum, expr, read, sh, sleep, time, true, aflse, wc
#      csplit, dd, patch, expand, file, iconv, ln, mkfifo, nl, od, pax, touch
#      compress, uncompress,  zcat, at, date, bg, fuser, chgrp, chown, id, ps,
#      uname, type, nohup, wait, who
#
# Example snippets to use for hacking
i=1; while [ ${i} -le 3 ]; do
  echo ${i}
  i=$(( i + 1 ))
done

# simpler alternative for smol loops
for i in $(seq 10); do
  echo "number $i"
done

# https://stackoverflow.com/a/53747300
s='A|B|C|D' # specify your "array" as a string with a sigil between elements
IFS='|'     # specify separator between elements
set -f      # disable glob expansion, so a * doesn't get replaced with a list of files

getNth()  { shift "$(( $1 + 1 ))"; printf '%s\n' "$1"; }
getLast() { getNth "$(( $(length "$@") - 1 ))" "$@"; }
length()  { echo "$#"; }

length $s   # emits 4
getNth 0 $s # emits A
getNth 1 $s # emits B
getLast $s  # emits D

s2='t1 t2 t3 t4'
set -f; IFS=' '      # IFS='\n' appears to be broken
for jar in ${s2}; do
  set +f; unset IFS
  echo "$jar"        # restore globbing and field splitting at all whitespace
done
set +f; unset IFS    # do it again in case $INPUT was empty
echo "done"


# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

var="abcdef"
removed_prefix="${var#a}"
removed_suffix="${var%e}"

# parameter expansion https://stackoverflow.com/a/16753536

# check posix conform, if executable exists
command -v 'tmux' 1> /dev/null
if test $? -ne 0; then
   echo "Please create dir dev/"
   exit 1
fi

# negation in posix
if ! test $? -eq 0; then
   echo "Please create dir dev/"
   exit 1
fi
# or (careful with spacing!)
if ! [ $? -eq 0 ]; then
   echo "Please create dir dev/"
   exit 1
fi

# based on https://github.com/dylanaraps/pure-sh-bible
TEST1=""
if test -n "${TEST1}"; then echo "length of string non-zero"; fi
if test -z "${TEST1}"; then echo "length of string zero"; fi

if test "${TEST1}" = "${TEST1}"; then echo "equal"; fi
if test "${TEST1}" != "${TEST1}"; then echo "non-equal"; fi
# numeric: - with eq,ne,gt,ge,lt,le
# file: - with e,f,d,h/L(symbolic link),w,x,s(non-empty)
# file: - with b(lock),c(haracter),g(set-group-id),p(ipe),t(terminal),u(set-user-id),S(socket)
# arithmetic: +,-,*,/,**(exponent),%(modulo),+=,-=,*=,/=,%=
# ${VAR//PATTERN/REPLACE} substitute with replacement
# ${VAR#PATTERN}   remove shortest match based on pattern from start
# ${VAR##PATTERN}  remove longest match based on pattern from start
# ${VAR%PATTERN}   remove shortest match based on pattern from end
# ${VAR%%PATTERN}  remove longest match based on pattern from end
# ${#VAR}          lenght of var in characters (utf8 ?)
# ${VAR:-STRING} If VAR is empty or unset, use STRING as its value.
# ${VAR-STRING}  If VAR is unset, use STRING as its value.
# ${VAR:=STRING} If VAR is empty or unset, set the value of VAR to STRING.
# ${VAR=STRING}  If VAR is unset, set the value of VAR to STRING.
# ${VAR:+STRING} If VAR is not empty, use STRING as its value.
# ${VAR+STRING}  If VAR is set, use STRING as its value.
# ${VAR:?STRING} Display an error if empty or unset.
# ${VAR?STRING}  Display an error if unset.
# $- Shell options
# $$ 	Current shell PID

env -i PATH="$PATH" ls
env -i HOME="$HOME" LC_CTYPE="${LC_ALL:-${LC_CTYPE:-$LANG}}" PATH="$PATH" USER="$USER" ls
ssh localhost ls
env -i bash --noprofile --norc -c "command"

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

# SHENNANIGAN
# Posix shell has no utility to remove control of process from host shell

# Get symbol information via
# type symbol

# SHENNANIGAN Shells other than powershell have no static and dynamic checks
# for types So one has to do regex pattern matching at runtime for type checks
# or hope that runtime type information are correct.

# assume: $1 is given
is_integer() {
  case $1 in
      ''|*[!0-9]*) echo 1 ;;
      *) echo 0 ;;
  esac
}
