#!/bin/sh

# manually
# git bisect start
# git bisect bad HEAD
# git bisect good LASTGOODCOMMIT
# git bisect reset
# inserting git bisect bad/git bisect good

# scripted
# git bisect run
#   (errorcode != 0 indicates failure and errorcode = 0 indicates success)
