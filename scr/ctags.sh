#!/usr/bin/env sh
# assume: Posix
# assume: Usage on Windows requires providing relative paths without path separator
set -e
PATH="/usr/local/bin:$PATH"
PID=$$
#if [ -z ${var+x} ]; then echo "'$1' is unset, need paths to create ctags for"; exit; fi

if test "$#" -lt 1; then
  echo "Usage: $0 FILE1 [.. FILEN], need paths to create ctags for" >&2
  exit 1
fi

trap 'rm -f "${PID}tags"' EXIT
#powershell: cd repo
#powershell: FILES=$(fd 'prefix.*' -t d --max-depth=1 --relative-path | TODO strip last / or \ of local dirs)
#powershell: ctags --recurse=yes --kinds-c++=+p --extras=+fq --sort=foldcase --c++-kinds=+p --fields=+iaS --extras=+q relativepath
ctags --recurse=yes --kinds-c++=+p -f "${PID}tags" --extras=+fq --sort=foldcase --c++-kinds=+p --fields=+iaS --extras=+q "$@"
mv "${PID}tags" "tags"
# Generate ctags with various options
# It may be required to define an ignorelist
# https://stackoverflow.com/questions/5626188/ctags-ignore-lists-for-libc6-libstdc-and-boost
# It may be interesting to automatically regenerate tags with git hooks, which
# one could setup via script or .git_templates
# https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html

# Most interesting options
# ctags --list-fields=c++
# ctags --list-extras=c++
# ctags --list-kinds=c++

#ctags files can be used to find a file very quickly.
#Just add the "--extras=+f" option in the ctags line.
#You may then open new files manually with autocompletion, with
#:tag myfile.cpp

# c++ flags
#--recurse=yes .
#-f tagfile
#--extras=+fq
#--sort=foldcase
#--c++-kinds=+p
#--fields=+iaS
#--extras=+q
#-L -/file (- for standard in) to specify where to read from (can also use last positions instead)
# --tag-relative (needed, if you want to move directories)
# --languages=-javascript,sql (disable languages)

# Note that there may be also other program that can generate ctags compatible information.
# For example, https://git.sr.ht/~gpanders/ztags or https://github.com/jstemmer/gotags
