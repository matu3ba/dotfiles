#!/bin/sh

# -- manually --
# git bisect start BADCOMMIT GOODCOMMIT
# git bisect start|bad HEAD|good LASTGOODCOMMIT
# git bisect reset
# inserting git bisect bad/git bisect good

# -- scripted --
# git bisect run ./script.sh
#   (errorcode != 0 indicates failure and errorcode = 0 indicates success)

# exit code of 125 asks "git bisect" to "skip" the current commit
# make || exit 125
# check for some output with
# ./app ARGS | grep 'YOUROUTPUT'

# Typically use for bisecting:
#git checkout LASTKNOWN_GOODCOMMIT
#git bisect start master HEAD
#git bisect run script.sh

#git bisect reset
#git switch master


# search through occurence of string in latest log file
# broken with rigrep: https://github.com/BurntSushi/ripgrep/issues/273
# ls -rt /tmp/fancydir/* | tail -1 | xargs tail -f
# ls -rt /tmp/fancydir/* | tail -1 | xargs grep -F 'some string'
# ls -rt /tmp/fancydir/* | tail -1 | xargs grep -i 'some string'
# return code 0 on success, 123 on failure to find string

# -e
# compilation + running
# +e
# ls + tail + xargs grep
# status=$?
# test $status -eq 0 && exit 1
# test $status -eq 1 && exit 0
