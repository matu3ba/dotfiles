#!/usr/bin/env sh
## delete regular files only depending on structure of dotfiles
## example: if .bashrc is regular file -> rm $HOME/.bashrc

# The following script assumes filenames do not contain
# control characters and dont contain leading dashes(-).
set -o errexit         # abort on nonzero exitstatus
set -o nounset         # abort on unbound variable
set -o pipefail        # don't hide errors within pipes

FAIL="TRUE" # will be filled with defaults
cd "${HOME}/dotfiles"
dotfilePaths="$(fd -uu --type f --ignore-file "$HOME/dotfiles/ignorefiles" --ignore-file "$HOME/dotfiles/.gitignore")"

for dfPath in $dotfilePaths; do
  printf '%-40s' "$dfPath"
  sysAbsPath="${HOME}/${dfPath}"
  if test -e "$sysAbsPath"; then
    if ! test -L "$sysAbsPath"; then
      if test -f "$sysAbsPath"; then #regular file?
        rm "$sysAbsPath"
        printf '%-20s' "removed"
        FAIL="FALSE"
      else
        printf '%-20s' "no symlink or regular file"
      fi
    else
      printf '%-20s' "is symlink"
    fi
  else
    printf '%-20s' "found no file"
  fi
  printf "\n"
done
if test "$FAIL" = "FALSE"; then
  echo "files were successfully removed"
else
  echo "no files were removed"
fi
