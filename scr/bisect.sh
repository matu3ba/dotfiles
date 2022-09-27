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
