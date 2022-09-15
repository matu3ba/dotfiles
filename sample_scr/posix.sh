#!/bin/sh
# unless commands return non-zero status, use
set -e
# temporary set
set +e
# and reset
set -e
# string/* is used verbatim without match, except we set nullglob
shopt -s nullglob
# disable it with `shopt -u nullglob`

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
