#!/bin/sh
# merge recursively found compile_commands.json files

command -v 'fd' 1>/dev/null
if test $? -ne 0; then
  # shellcheck disable=SC2016
  echo 'Please install fd with `cargo install fd-find`'
  exit 1
fi

if test $# -eq 0; then
  echo 'Usage: ./merge_compilercommands.sh [-E exclude..]'
fi

COMPILE_DATABASES=$(fd "$@" compile_commands.json)
jq -s 'add' "$COMPILE_DATABASES" >compile_commands.json
