
# https://stackoverflow.com/questions/52798129/in-fish-shell-how-to-check-if-a-variable-is-a-number
function string  --wraps=string
  if set -q argv[1]; and [ $argv[1] = "is" ]
    if not set -q argv[2]
      echo "error: usage..." >&2
      return
    end
    set -l pattern
    switch $argv[2]
      case int integer
        set pattern '^[+-]?\d+$'
      case hex hexadecimal xdigit
        set pattern '^[[:xdigit:]]+$'
      case oct octal
        set pattern '^[0-7]+$'
      case bin binary
        set pattern '^[01]+$'
      case float double
        set pattern '^[+-]?(?:\d+(\.\d+)?|\.\d+)$'
      case alpha
        set pattern '^[[:alpha:]]+$'
      case alnum
        set pattern '^[[:alnum:]]+$'
      case '*'
        echo "unknown class..." >&2
        return
    end
    set argv match --quiet --regex -- $pattern $argv[3]
  end
  builtin string $argv
end