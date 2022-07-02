#!/bin/sh
# Stub to get necessary files

ROOT=$(git rev-parse --show-toplevel)
CWD=$(pwd)
if test "${ROOT}" -ne "${CWD}"; then
  echo 'CWD != GIT_ROOT'
  exit
fi

# Rsync necessary files to git worktree
# rsync -av --delete "${ROOT}/../master/dir/" "${ROOT}/dir/"
