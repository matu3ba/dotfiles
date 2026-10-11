set -l options 'help' 'crash'
argparse $options -- $argv
or exit 1

# string escape masks injections, control chars, format strings including line break
# --style=var is very conservative up to being unreadable for non-ascii symbols
function safe_print
  string escape --style=script -- $argv
end

# combines all args with ' ' and masks them afterwards
# --style=var is very conservative up to being unreadable for non-ascii symbols
function safe_print_inline
  string escape --style=script -- (string join ' ' -- $argv)
end

# general
# 1 dont use eval, if possible.
#   I wont list the problems here.
# 2 there are only trade-offs due to in-band signaling

# Vector 1: Semicolon / Code Injection & Logic Operators
set VAR (string unescape '; id; whoami')
safe_print $VAR
safe_print_inline $VAR

set MAL "&& echo 'Hacked'"
if set -q _flag_crash
  echo "$MAL"
end
eval "echo $(safe_print $MAL)"
eval "echo $(safe_print_inline $MAL)"

set MAL "|| echo 'Hacked'"
if set -q _flag_crash
  false "$MAL"
  eval "false $MAL"
end
eval "false $(safe_print $MAL)"
eval "false $(safe_print_inline $MAL)"

# Vector 2: Subshell-Exec (Backticks / Dollar-Brackets)
set MAL 'uname -a'
if set -q _flag_crash
  eval "$MAL"
end
eval "$(safe_print $MAL)"
eval "$(safe_print_inline $MAL)"

# Wildcards
set MAL './*'
# too evil: eval "$MAL"
eval "$(safe_print $MAL)"
eval "$(safe_print_inline $MAL)"

# Vector 3: printf Format-String-Attacks (Missing Arguments / Memory-Modifiers)
set MAL "%s%s%s%s%s%s%d%x"
if set -q _flag_crash
  echo $MAL
  printf $MAL
end
safe_print $MAL
safe_print_inline $MAL

set MAL "-v target_var"
if set -q _flag_crash
  echo $MAL
end
safe_print $MAL
safe_print_inline $MAL

set MAL "%n"
if set -q _flag_crash
  echo $MAL
end
safe_print $MAL
safe_print_inline $MAL

# Vector 4: Terminal ANSI-Escape-Sequenzen (Device Status / Visual Spoofing)
set MAL (string unescape "\e[5n")
if set -q _flag_crash
  echo $MAL
  printf '%s\n' -- $MAL
end
safe_print $MAL
safe_print_inline $MAL

set MAL (string unescape "ERROR: CRITICAL FAILURE\e[2K\r[OK] System healthy.")
if set -q _flag_crash
  echo $MAL
  printf '%s\n' -- $MAL
end
safe_print $MAL
safe_print_inline $MAL

# Scroll / Screen Clearance (Can hide previous logs from the developer's view)
set MAL (string unescape "\e[2J\e[H")
if set -q _flag_crash
  echo $MAL
  printf '%s\n' -- $MAL
end
safe_print $MAL
safe_print_inline $MAL

# Operating System Command (OSC) window title modification
# Attempts to silently rename the developer's terminal tab/window title
set MAL (string unescape "\e]0;HACKED_TERMINAL\a")
if set -q _flag_crash
  echo $MAL
  printf '%s\n' -- $MAL
end
safe_print $MAL
safe_print_inline $MAL
