#!/usr/bin/env bash
# wsl bash ./git_worktrees_setup.sh

# set -x
set -eou
trap 'cd ${CWD}' EXIT HUP INT QUIT SIGSEGV TERM
CWD=$(pwd)

# assume: $1 contains https..dirname.git
makeWorkTree() {
  worktreesdir=$(basename -s .git "$1")
  if test -e "$worktreesdir"; then
    echo "worktreesdir $worktreesdir already exists, skipping.."
    return
  fi
  echo "$worktreesdir"
  mkdir "$worktreesdir"
  cd "$worktreesdir"
  git clone --bare "$1" .bare
  # make sure git knows where the gitdir is
  echo "gitdir: ./.bare" > .git
  git worktree add master
  cd ..
}

# makeWorkTree GIT_REMOTE
