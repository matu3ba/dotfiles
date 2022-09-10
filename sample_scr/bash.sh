#!/usr/bin/env bash

# unless commands return non-zero status, use
set -e
# temporary set
set +e
# and reset
set -e

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
