#!/usr/bin/env sh
## search sub-folder paths and remove symlinks of un-ignored files
## example: if .bashrc is symlink -> rm $HOME/.bashrc

# The following script assumes filenames do not contain
# control characters and dont contain leading dashes(-).
set -o errexit         # abort on nonzero exitstatus
set -o nounset         # abort on unbound variable
set -o pipefail        # don't hide errors within pipes
IFS="$(printf '\n\t')" # change IFS to just newline and tab

FAIL="FALSE" # will be filled with defaults
cd "${HOME}/dotfiles"
dotfilePaths="$(fd -uu --type f --ignore-file "$HOME/dotfiles/ignorefiles" --ignore-file "$HOME/dotfiles/.gitignore")"

for dfPath in $dotfilePaths; do
  printf '%-40s' "${dfPath}"
  #echo "${dfPath}"
  dfabsPath="${HOME}/dotfiles/${dfPath}"
  canonpath=$(realpath "${dfabsPath}")
  symlinkAbsPath="${HOME}/${dfPath}"
  if test -e "${symlinkAbsPath}"; then
    if ! test -L "${symlinkAbsPath}"; then
      FAIL="TRUE"
      printf '%-20s' "user profile: found file other than symlink"
    else
      linkTarget=$(readlink -e "${symlinkAbsPath}")
      #echo "linkTarget: ${linkTarget}"
      #echo "dfabsPath: ${dfabsPath}"
      #echo "canonpath: ${canonpath}"
      if test "${linkTarget}" != "${canonpath}"; then
        FAIL="TRUE"
        printf '%-20s' "symlink broken"
      else
        rm "${symlinkAbsPath}"
        printf '%-20s' "removed valid symlink"
      fi
    fi
  else
    printf '%-20s' "user profile: found no symlink"
  fi
  printf "\n"
done
echo "failure occurred: $FAIL"
