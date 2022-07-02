#!/bin/sh
# Script to setup worktree from git bare repo
# Asserts: Directory structure is
# barerepo/
# barerepo/branch
# barerepo/.bare
# Assumes:
# barerepo/getFiles.sh
# barerepo/min_ctags.sh
# barerepo/prepareBuild.sh
# This could be checked with
# GITDIR=$(git rev-parse --git-dir)
# and dirname ${GIDIR} -ne

set -e

WORKTREE_ROOT=$(git rev-parse --show-toplevel)
CWD=$(pwd)
if test "${WORKTREE_ROOT}" -ne "${CWD}"; then
  echo 'CWD != WORKTREE_ROOT'
  exit
fi
GITDIR=$(git rev-parse --git-dir)
BASEDIR_GITDIR=$(dirname "$GITDIR")
BASEDIR_WT_ROOT=$(dirname "$WORKTREE_ROOT")
if test "${BASEDIR_GITDIR}" -ne "${BASEDIR_WT_ROOT}"; then
  echo 'No structure basedir/.bare basedir/branch'
  exit
fi
../getFiles.sh
../min_ctags.sh
../prepareBuild.sh
