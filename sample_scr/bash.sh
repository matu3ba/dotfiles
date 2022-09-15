#!/usr/bin/env bash
# for general posix things, see ./posix.sh

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
