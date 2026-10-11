#!/usr/bin/env sh

# Security Options
# 1. safe redirect for logs
#    * eval exploits still work
#    * (possibly surprising) data corruption
#    * slow
safe_print() {
    printf '%s\n' "$@" | cat -v
}
safe_print_inline() {
    first=1
    for arg in "$@"; do
        if [ $first -eq 1 ]; then
            printf '%s' "$arg"
            first=0
        else
            printf ' %s' "$arg"
        fi
    done | cat -v
    printf '\n'
}
# 2. bash: eval "echo ${VAR@Q}"
# 3. bash/ksh/zsh: printf '%q'

# general
# 1 dont use eval, if possible.
#   example
#     VAR=$'\e]0;HACKED_TERMINAL\a'
#     ok: echo ${VAR@Q}
#     wtf: eval "echo ${VAR@Q}"
# 2 there are only trade-offs due to in-band signaling

# 1. Standard semicolon separator

VAR="; id; whoami"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print "$VAR"
safe_print_inline "$VAR"

# 2. Logical operators (executes if the first command succeeds/fails)
VAR="&& rm -rf /tmp/fake_target"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

VAR="|| echo 'Hacked'"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 3. Classic backtick subshell execution
# immediately execute and replace result in string: VAR="`uname -a`"
VAR='`uname -a`'
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 4. Modern dollar-parenthesis subshell execution
VAR="\$(env)"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 5. Piping into an interpreter
VAR="| sh"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 6. Globbing / Wildcards (Tests if word splitting leaks filesystem structures)
VAR="*"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

VAR="??"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 1. Missing argument leaks/crashes
# * only destructive safety
VAR="%s%s%s%s%s%s%d%x"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 2. Variable assignment flag (Supported by Bash built-in printf)
# If vulnerable, this will try to overwrite an internal variable named 'target_var'
VAR="-v target_var"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 3. Standard C-style memory modifier format (Often causes unexpected printing bugs)
# * only destructive safety
VAR="%n"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR
# 1. Device Status Report (Forces the terminal to type data back into the prompt buffer)
# (Danger level: High on old/unpatched terminal emulators)
# * only destructive safety
VAR=$'\e[5n'
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 2. Line Erasure / Visual Spoofing
# This prints 'ERROR', moves the cursor back, deletes the line, and prints '[OK]'
# * only destructive safety
VAR=$'ERROR: CRITICAL FAILURE\e[2K\r[OK] System healthy.'
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 3. Scroll / Screen Clearance (Can hide previous logs from the developer's view)
# * only destructive safety
VAR=$'\e[2J\e[H'
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR

# 4. Operating System Command (OSC) window title modification
# Attempts to silently rename the developer's terminal tab/window title
# * only destructive safety
VAR=$'\e]0;HACKED_TERMINAL\a'
# eval "echo ${VAR@Q}"
# echo "$VAR"
# printf '%s\n' "$VAR"
echo ${VAR@Q}
printf '%q\n' "$VAR"
safe_print $VAR
safe_print_inline $VAR
