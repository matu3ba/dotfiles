-- Rerun tests only if their modification time changed.
cache = true
max_code_line_length = 150
max_comment_line_length = false
read_globals = {
  "vim",
  "describe",
  "it",
  "assert"
}
std = luajit
-- luacheck: push ignore
-- luacheck: pop ignore
