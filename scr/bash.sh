#!/usr/bin/env bash
set -e
CWD=$(pwd)
trap "cd ${CWD}" EXIT HUP INT QUIT SIGSEGV TERM

shopt -s nullglob

# for general posix things, see ./posix.sh

# string/* is used verbatim without match, except we set nullglob
shopt -s nullglob
# disable it with `shopt -u nullglob`

# no cd around after failure
CWD=$(pwd)
trap "cd ${CWD}" EXIT

# loop array by index
SIZES=(
  200 800
)
for ((i=0;i<${#SIZES[*]};++i)); do
  echo "${SIZES[i]}"
done

# jobs -l                                               to list all jobs
# disown [Job|-r RunningJob|-a|-h JobWithoutSIGHUB]     with -a for all jobs
#   Note: disown does not remove control from shell, so the job still gets terminated once shell is terminated. Use setsid for this.
# ps                                                    report snapshot of current process
# SHENNANIGAN 'setsid --fork is the only way to properly ensure that a command is run as a detached process.'
# setsid --fork                                         run program in new session
