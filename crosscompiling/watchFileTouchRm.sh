#!/bin/sh
# This script continuosly watches the files in directory $1
# and applies an action on any change (file addition or removal).
# This is useful, if you dont have a compiler on the target or
# crosscompiling is tricky (without zig).

SIG=1
SIG0=$SIG
while [ $SIG != 0 ] ; do
 while [ $SIG = $SIG0 ] ; do
   SIG=`ls -1 $1 | md5sum | cut -c1-32`
   sleep 2 ######### TIMEOUT #########
 done
 SIG0=$SIG
 ######### ACTION: DESCRIPTION #########
 ls -lrt $1 | tail -n 1
done
