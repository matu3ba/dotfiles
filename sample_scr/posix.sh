#!/bin/sh
# Example snippets to use for hacking
i=1; while [ ${i} -le 3 ]; do
  echo ${i}
  i=$(( i + 1 ))
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
