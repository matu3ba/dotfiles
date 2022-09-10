#!/bin/sh
# Script to build master from any worktree
# asserts CWD = shareddir or CWD = shareddir/branchdir

set -e

CWD=$(pwd)
trap "cd ${CWD}" EXIT

if test -d "${CWD}/master"; then
  # it must hold GITDIR = GITCOMMDIR
  echo "CWD != ROOT"
  GITDIR=$(git rev-parse --git-dir)
  GITCOMMDIR=$(git rev-parse --git-common-dir)
  if test "${GITDIR}" != "${GITCOMMDIR}"; then
    echo "GITDIR = GITCOMMONDIR (no bare repo), exiting.."; exit 1
  fi
  cd master
else
  WORKTREEROOT=$(git rev-parse --show-toplevel) # failure outside of worktree
  if test "${WORKTREEROOT}" != "${CWD}"; then
    echo "must build from WORKTREEROOT, exiting.."; exit 1
  fi
  pathtomaster="${WORKTREEROOT}/../master"
  cd "${pathtomaster}"
fi

# commands to run on master worktree
